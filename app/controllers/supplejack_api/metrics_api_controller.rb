module SupplejackApi
  class MetricsApiController < ApplicationController
    API_VERSIONS = {
      'v1' => MetricsApi::V1::Api
    }

    def endpoint
      api_version = params[:version]
      api = API_VERSIONS[api_version].new(params.dup)

      render json: api.call.to_json(include_root: false)
    end
  end
end
