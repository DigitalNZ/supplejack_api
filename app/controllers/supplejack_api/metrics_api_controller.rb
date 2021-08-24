# frozen_string_literal: true

module SupplejackApi
  class MetricsApiController < SupplejackApplicationController
    skip_before_action :authenticate_user!, raise: false

    def root
      api_response = MetricsApi::V3::Endpoints::Root.new(params.dup).call

      if api_response.is_a? Hash
        render json: { errors: api_response[:exception][:message] }, status: api_response[:exception][:status]
      else
        render json: api_response.to_json(include_root: false) unless performed?
      end
    end

    def facets
      render json: FacetsHelper
        .get_list_of_facet_values('display_collection')
        .to_json(include_root: false) unless performed?
    end

    def global
      start_date = parse_date_param(params[:start_date]) || Time.now.utc.yesterday
      end_date = parse_date_param(params[:end_date]) || Time.now.utc.to_date

      render json: DailyMetrics.created_between(start_date, end_date),
             each_serializer: DailyMetricsSerializer,
             root: false
    end

    private

    def parse_date_param(date_param)
      return nil if date_param.blank?

      Date.parse(date_param)
    end
  end
end
