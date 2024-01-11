# frozen_string_literal: true

module SupplejackApi
  class MetricsApiController < SupplejackApplicationController
    skip_before_action :authenticate_user!, raise: false

    ALLOWED_METRICS = %w[page_views appeared_in_searches].freeze
    ALLOWED_TYPES   = %w[record collection].freeze

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

      if type == 'collection'
        metrics = SupplejackApi::TopCollectionMetric.created_between(start_date, end_date).where(metric: metric)
        sorted_metrics = combined_collection_metrics(metrics).sort_by { |metric| metric[:count] }.reverse.take(10)
      else
        metrics = SupplejackApi::TopMetric.created_between(start_date, end_date).where(metric: metric)
        sorted_metrics = sort_record_metrics(combined_record_metrics(metrics))
      end

      render json: {
        type: type,
        metric: metric,
        results: sorted_metrics
      }
    end

    private

    def combined_record_metrics(metrics)
      metrics.reduce({}) do |results, metric|
        results.merge(metric.results) do |_record_id, count_one, count_two|
          count_one + count_two
        end
      end
    end

    def combined_collection_metrics(metrics)
      collections = metrics.map(&:display_collection).uniq

      collections.map do |collection|
        collection_metrics = metrics.where(display_collection: collection)

        {
          'display_collection': collection,
          'count': sum_collection_metrics(collection_metrics),
          'top_ten_records': sort_record_metrics(combined_record_metrics(collection_metrics))
        }
      end
    end

    def sum_collection_metrics(collection_metrics)
      collection_metrics.map do |metric|
        metric.results.sum { |_key, value| value }
      end.sum
    end

    def sort_record_metrics(record_metrics)
      metrics = record_metrics.sort_by(&:last).reverse.take(10)
      metrics.map! { |record_id, count| { record_id: record_id.to_i, count: count } }
    end

    def metric
      return 'page_views' if ALLOWED_METRICS.exclude?(params[:metric])

      params[:metric]
    end

    def type
      return 'record' if ALLOWED_TYPES.exclude?(params[:type])

      params[:type]
    end
  end
end
