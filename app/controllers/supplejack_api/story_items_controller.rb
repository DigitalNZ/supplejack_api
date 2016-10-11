# frozen_string_literal: true
module SupplejackApi
  class StoryItemsController < ApplicationController
    def index
      render_response(:story_items)
    end

    def show
      render_response(:story_item)
    end

    def create
      render_response(:story_items)
    end

    def update
      # I dont like this
      case request.method
      when 'PUT' then render_response(:story_items)
      when 'PATCH' then render_response(:story_item)
      end
    end

    def destroy
      render_response(:story_item)
    end

    private

    # Renders the response for the controller action
    #
    # @author Taylor
    # @last_modified Eddie
    # @param endpoint [Symbol] the service endpoint
    def render_response(endpoint)
      api = StoriesApi::V3::Api.new(params.dup, endpoint, request.method.downcase.to_sym)

      api_response = api.errors ? api.errors : api.call

      handle_errors(api_response)

      # don't double render if we've already rendered an exception
      render json: api_response[:payload].to_json(include_root: false), status: api_response[:status] unless performed?
    end

    # Renders error response for the controller action
    #
    # @author Taylor
    # @last_modified Eddie
    # @param endpoint [Symbol] the response
    def handle_errors(api_response)
      return unless api_response.key? :exception

      render json: { errors: api_response[:exception][:message] }, status: api_response[:status]
    end
  end
end
