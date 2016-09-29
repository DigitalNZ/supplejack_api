# frozen_string_literal: true
module StoriesApi
  module V3
    module Helpers
      def current_user(params)
        @current_user ||= SupplejackApi::User.find_by_api_key(params[:api_key])
      end
    end
  end
end
