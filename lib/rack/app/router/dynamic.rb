class Rack::App::Router::Dynamic < Rack::App::Router::Base

  require 'rack/app/router/dynamic/request_path_part_placeholder'
  DYNAMIC_REQUEST_PATH_PART = RequestPathPartPlaceholder.new('DYNAMIC_REQUEST_PATH_PART')
  MOUNTED_DIRECTORY = RequestPathPartPlaceholder.new('MOUNTED_DIRECTORY')
  MOUNTED_APPLICATION = RequestPathPartPlaceholder.new('MOUNTED_APPLICATION')

  protected

  def initialize
    @http_method_cluster = {}
  end

  def path_part_is_dynamic?(path_part_str)
    !!(path_part_str.to_s =~ /^:\w+$/i)
  end

  def deep_merge!(hash, other_hash)
    Rack::App::Utils.deep_merge(hash, other_hash)
  end

  def main_cluster(request_method)
    (@http_method_cluster[request_method.to_s.upcase] ||= {})
  end

  def path_part_is_a_mounted_directory?(path_part)
    path_part == Rack::App::Constants::MOUNTED_DIRECTORY

    (path_part == '**' or path_part == '*')
  end

  def path_part_is_a_mounted_rack_based_application?(path_part)
    path_part == Rack::App::Constants::RACK_BASED_APPLICATION
  end

  def clean_routes!
    @http_method_cluster.clear
  end

  def compile_registered_endpoints!
    endpoints.each do |endpoint|
      compile_endpoint!(endpoint)
    end
  end

  def compile_endpoint!(endpoint)
    endpoint.request_paths.each do |request_path|
      compile_request_path!(request_path, endpoint)
    end
  end

  def compile_request_path!(request_path, endpoint)
    request_method = endpoint.request_method

    clusters_for(request_method) do |current_cluster|

      break_build = false
      path_params = {}
      options = {}

      builder = Rack::Builder.new
      builder.use(Rack::App::Middlewares::Configuration::PathParamsMatcher, path_params)

      request_path_parts = request_path.split('/')
      request_path_parts.each.with_index do |path_part, index|

        new_cluster_name = if path_part_is_dynamic?(path_part)
                             path_params[index]= path_part.sub(/^:/, '')
                             DYNAMIC_REQUEST_PATH_PART

                           elsif path_part_is_a_mounted_directory?(path_part)
                             break_build = true
                             MOUNTED_DIRECTORY

                           elsif path_part_is_a_mounted_rack_based_application?(path_part)
                             break_build = true
                             builder.use(
                              Rack::App::Middlewares::PathInfoCutter,
                              calculate_mount_path(request_path_parts)
                             )
                             MOUNTED_APPLICATION

                           else
                             path_part
                           end

        current_cluster = (current_cluster[new_cluster_name] ||= {})
        break if break_build

      end


      builder.run(as_app(endpoint))
      current_cluster[:app]= builder.to_app

      current_cluster[:endpoint]= endpoint
      if current_cluster[:endpoint].respond_to?(:register_path_params_matcher)
        current_cluster[:endpoint].register_path_params_matcher(path_params)
      end

      current_cluster[:options]= options
    end
  end

  def calculate_mount_path(request_path_parts)
    mount_path_parts = (request_path_parts - [Rack::App::Constants::RACK_BASED_APPLICATION, ''])
    mount_path_parts.empty? ? '' : Rack::App::Utils.join(mount_path_parts)
  end

  def clusters_for(request_method)
    if ::Rack::App::Constants::HTTP::METHOD::ANY == request_method
      supported_http_protocols.each do |cluster_type|
        yield(main_cluster(cluster_type))
      end
    else
      yield(main_cluster(request_method))
    end
  end

  def supported_http_protocols
    ::Rack::App::Constants::HTTP::METHODS
  end


  def fetch_context(request_method, path_info)
    normalized_request_path = Rack::App::Utils.normalize_path(path_info)

    last_mounted_directory = nil
    last_mounted_app = nil
    current_cluster = main_cluster(request_method)
    normalized_request_path.split('/').each do |path_part|

      last_mounted_directory = current_cluster[MOUNTED_DIRECTORY] || last_mounted_directory
      last_mounted_app = current_cluster[MOUNTED_APPLICATION] || last_mounted_app

      current_cluster = current_cluster[path_part] || current_cluster[DYNAMIC_REQUEST_PATH_PART]

      last_mounted_directory = (current_cluster || {})[MOUNTED_DIRECTORY] || last_mounted_directory
      last_mounted_app = (current_cluster || {})[MOUNTED_APPLICATION] || last_mounted_app

      if current_cluster.nil?
        if last_mounted_directory
          current_cluster = last_mounted_directory
          break

        elsif last_mounted_app
          current_cluster = last_mounted_app
          break

        else
          return nil

        end
      end

    end

    return current_cluster

  end

end
