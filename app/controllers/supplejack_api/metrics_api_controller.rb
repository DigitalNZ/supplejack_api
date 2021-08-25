# frozen_string_literal: true

module SupplejackApi
  class MetricsApiController < SupplejackApplicationController
    skip_before_action :authenticate_user!, raise: false

    def root
      api_response = MetricsApi::Root.new(params.dup).call

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
      start_date = MetricsHelper.start_date_with(params[:start_date])
      end_date = MetricsHelper.end_date_with(params[:end_date])

      render json: DailyMetrics.created_between(start_date, end_date),
             each_serializer: DailyMetricsSerializer,
             root: false
    end
  end
end
