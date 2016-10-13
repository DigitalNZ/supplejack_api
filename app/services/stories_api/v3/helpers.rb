# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module StoriesApi
  module V3
    module Helpers
      def current_user(params)
        @current_user ||= SupplejackApi::User.find_by_api_key(params[:api_key])
      end

      def create_error(error = nil, options = {})
        "StoriesApi::V3::Errors::#{error}".constantize.new(options).error
      end

      def create_response(status: nil, payload: nil)
        response = { status: status }
        response[:payload] = payload unless payload.nil?

        response
      end
    end
  end
end
