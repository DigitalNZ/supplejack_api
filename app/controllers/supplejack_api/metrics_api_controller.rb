# frozen_string_literal: true

module SupplejackApi
  class MetricsApiController < SupplejackApplicationController
    skip_before_action :authenticate_user!, raise: false

    def root
      api_response = MetricsApi::V3::Endpoints::Root.new(params.dup).call

      handle_errors(api_response)

      render json: api_response.to_json(include_root: false) unless performed?
    end

    def facets
      api_response = MetricsApi::V3::Endpoints::Facets.new(params.dup).call

      render json: api_response.to_json(include_root: false) unless performed?
    end

    def global
      api_response = MetricsApi::V3::Endpoints::Global.new(params.dup).call

      render json: api_response.to_json(include_root: false) unless performed?
    end

    private

    def handle_errors(api_response)
      return unless api_response.is_a? Hash

      ex = api_response[:exception]

      render json: { errors: ex[:message] }, status: ex[:status]
    end
  end
end
