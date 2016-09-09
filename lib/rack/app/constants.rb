module Rack::App::Constants

  module HTTP

    module METHOD
      ANY     = 'ANY'.freeze
      GET     = 'GET'.freeze
      POST    = 'POST'.freeze
      PUT     = 'PUT'.freeze
      PATCH   = 'PATCH'.freeze
      DELETE  = 'DELETE'.freeze
      HEAD    = 'HEAD'.freeze
      OPTIONS = 'OPTIONS'.freeze
      LINK    = 'LINK'.freeze
      UNLINK  = 'UNLINK'.freeze
      TRACE   = 'TRACE'.freeze
    end

    METHODS = (METHOD.constants - [:ANY]).map(&:to_s).freeze

  end

  module ENV
    PATH_INFO = (defined?(::Rack::PATH_INFO) ? ::Rack::PATH_INFO : "PATH_INFO".freeze)
    REQUEST_HANDLER = 'rack-app.handler'
    SERIALIZER = 'rack-app.serializer'
    PARSED_PARAMS = 'rack-app.parsed_params'
    VALIDATED_PARAMS = 'rack-app.validated_params'
    ORIGINAL_PATH_INFO = 'rack-app.original_path_info'.freeze
    PATH_PARAMS_MATCHER = 'rack-app.path_params_matcher'.freeze
    METHODOVERRIDE_ORIGINAL_METHOD = 'rack-app.methodoverride.original_method'.freeze
  end

  MOUNTED_DIRECTORY = '[Mounted Directory]'.freeze
  RACK_BASED_APPLICATION = '[Mounted Rack Application]'.freeze

end
