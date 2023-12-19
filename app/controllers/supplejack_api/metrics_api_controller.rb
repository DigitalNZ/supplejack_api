# frozen_string_literal: true

module SupplejackApi
  class MetricsApiController < SupplejackApplicationController
    skip_before_action :authenticate_user!, raise: false

    ALLOWED_METRICS = %w[page_views appeared_in_searches].freeze

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

    def top
      start_date = MetricsHelper.start_date_with(params[:start_date])
      end_date = MetricsHelper.end_date_with(params[:end_date])

      metrics = SupplejackApi::TopMetric.created_between(start_date, end_date).where(metric: metric)

      sorted_metrics = combined_metrics(metrics).sort_by(&:last).reverse.take(10)
      sorted_metrics.map! { |record_id, count| { record_id: record_id.to_i, count: count } }

      render json: sorted_metrics
    end

    private

    def combined_metrics(metrics)
      metrics.reduce({}) do |results, metric|
        results.merge(metric.results) do |_record_id, count_one, count_two|
          count_one + count_two
        end
      end
    end

    def metric
      return 'page_views' if ALLOWED_METRICS.exclude?(params[:page_views])

      params[:page_views]
    end
  end
end
