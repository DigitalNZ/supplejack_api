# frozen_string_literal: true



module StoriesApi
  module V3
    class Api
      ENDPOINT_BASE = 'StoriesApi::V3::Endpoints::'

      attr_reader :params, :method, :endpoint_object, :errors

      def initialize(params, endpoint, method)
        @params = params
        endpoint = (ENDPOINT_BASE + endpoint.to_s.camelize).constantize
        @endpoint_object = endpoint.new(params)
        @errors = @endpoint_object.errors
        @method = method
      end

      def call
        endpoint_object.send(method)
      end
    end
  end
end
