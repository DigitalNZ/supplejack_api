# frozen_string_literal: true
module StoriesApi
  module V3
    module Helpers
      def current_user(params)
        @current_user ||= SupplejackApi::User.find_by_api_key(params[:api_key])
      end

      def create_exception(error = nil, options = {})
        "StoriesApi::V3::Errors::#{error}".constantize.new(options).error
      end

      def create_exception_old(status: nil, message: nil)
        {
          status: status,
          exception: {
            message: message
          }
        }
      end

      def create_response(status: nil, payload: nil)
        response = { status: status }
        response[:payload] = payload unless payload.nil?

        response
      end
    end
  end
end
