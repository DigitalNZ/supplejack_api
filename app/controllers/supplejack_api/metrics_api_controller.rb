module SupplejackApi
  class MetricsApiController < ApplicationController
    skip_before_filter :authenticate_user!

    API_VERSIONS = {
      'v3' => MetricsApi::V3::Api
    }

    def root
      render_response(:root)
    end

    def extended
      render_response(:extended)
    end

    def facets
      render_response(:facets)
    end

    private

    def render_response(endpoint)
      api_version = params[:version]
      api = API_VERSIONS[api_version].new(params.dup, endpoint)

      api_response = api.call

      handle_errors(api_response)

      # don't double render if we've already rendered an exception
      render json: api_response.to_json(include_root: false) unless performed?
    end

    def handle_errors(api_response)
      return unless api_response.is_a? Hash

      ex = api_response[:exception]

      render json: {errors: ex[:message]}, status: ex[:status]
    end
  end
end
