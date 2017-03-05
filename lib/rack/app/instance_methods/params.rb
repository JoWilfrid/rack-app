# frozen_string_literal: true
module Rack::App::InstanceMethods::Params

  E = ::Rack::App::Constants::ENV

  def params
    request.env[E::PARAMS].to_hash
  end

  def validated_params
    request.env[E::PARAMS].validated_params
  end

  def path_segments_params
    request.env[E::PARAMS].path_segments_params
  end

  def query_string_params
    request.env[E::PARAMS].query_string_params
  end

end
