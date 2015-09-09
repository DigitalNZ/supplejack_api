require 'pry'

module SupplejackApi
  class MetricsApiController < ApplicationController
    API_VERSIONS = {
      'v1' => MetricsApi::V1::Api
    }

    def endpoint
      api_version = params[:version]
      api = API_VERSIONS[api_version].new(params[:start_date], params[:end_date], params[:metrics])

      render json: api.call
    end
  end
end
