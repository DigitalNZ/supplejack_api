# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
