module SupplejackApi
  class StoriesController < ApplicationController
    def index
      render_response(:stories)
    end

    def show
    end

    def create
    end

    def update
    end

    def destroy
    end

    private

    def render_response(endpoint)
      api = StoriesApi::V3::Api.new(params.dup, endpoint, request.method.downcase.to_sym)

      api_response = api.call

      handle_errors(api_response)

      # don't double render if we've already rendered an exception
      render json: api_response[:payload].to_json(include_root: false), status: api_response[:status] unless performed?
    end

    def handle_errors(api_response)
      return unless api_response.has_key? :exception

      render json: { errors: api_response[:exception][:message] }, status: api_response[:status]
    end
  end
end
