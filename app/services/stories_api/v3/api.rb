# frozen_string_literal: true
module StoriesApi
  module V3
    class Api
      ENDPOINT_BASE = 'StoriesApi::V3::Endpoints::'

      attr_reader :params, :endpoint, :method

      def initialize(params, endpoint, method)
        @params = params
        @endpoint = (ENDPOINT_BASE + endpoint.to_s.camelize).constantize
        @method = method
      end

      def call
        endpoint.new(params).send(method)
      end
    end
  end
end
