# frozen_string_literal: true

# module MetricsApi
#   module V3
#     # API entry point for V3 of the MetricsAPI
#     #
#     # It takes in the request parameters and
#     # generates the metrics JSON the API should
#     # respond with
#     class Api
#       ENDPOINT_BASE = 'MetricsApi::V3::Endpoints::'

#       attr_reader :params, :endpoint

#       # @param params [Hash] request parameters hash, passed onto active endpoint
#       # @param endpoint [Symbol] endpoint this API requests is for
#       def initialize(params, endpoint)
#         @params = params
#         @endpoint = (ENDPOINT_BASE + endpoint.to_s.camelize).constantize
#       end

#       # Generates an API response using the parameters passed in when the class is created.
#       # This response has already been presented and is ready to deliver to the client
#       #
#       # @return [Array<Hash>] the generated API response
#       def call
#         endpoint.new(params).call
#       end
#     end
#   end
# end
