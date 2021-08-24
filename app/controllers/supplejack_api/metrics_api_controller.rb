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
      start_date = parse_date_param(params[:start_date]) || Time.now.utc.yesterday
      end_date = parse_date_param(params[:end_date]) || Time.now.utc.to_date

      render json: SupplejackApi::DailyMetrics.created_between(start_date, end_date),
             each_serializer: DailyMetricsSerializer,
             root: false
    end

    private

    def handle_errors(api_response)
      return unless api_response.is_a? Hash

      ex = api_response[:exception]

      render json: { errors: ex[:message] }, status: ex[:status]
    end

    def parse_date_param(date_param)
      return nil if date_param.blank?

      Date.parse(date_param)
    end
  end
end
