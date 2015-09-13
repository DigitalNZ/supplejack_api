module MetricsApi
  module V1
    class Api
      PRESENTER_BASE = "MetricsApi::V1::Presenters::"
      METRICS_TO_MODEL = {
        'display_collection' => SupplejackApi::DailyItemMetric,
        'usage' => SupplejackApi::UsageMetrics
      }

      attr_reader :start_date, :end_date, :metrics

      def initialize(start_date, end_date, metrics)
        @start_date = start_date || Date.current
        @end_date = end_date
        @metrics = metrics
      end

      def call
        sub_metric_objects = @metrics.map do |metric|
          metric_model = METRICS_TO_MODEL[metric]
          presenter = (PRESENTER_BASE + metric.capitalize).constantize
          
          metric_model.created_between(@start_date, @end_date).map(&presenter)
        end

        metrics_information = SupplejackApi::DailyItemMetric.created_between(@start_date, @end_date).map do |metric|
          {
            day: metric.day,
            total_active_records: metric.total_active_records,
            total_new_records: 0
          }
        end

        metrics_information.zip(sub_metric_objects).map(&MetricsApi::V1::Presenters::ApiResponse)
      end
    end
  end
end
