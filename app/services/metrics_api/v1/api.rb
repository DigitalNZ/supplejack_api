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
        @end_date = end_date || Date.current
        @metrics =  metrics || ['usage', 'display_collection']
      end

      def call
        metrics_information = SupplejackApi::DailyItemMetric.created_between(start_date, end_date).map do |metric|
          base_object = {
            day: metric.day,
            total_active_records: metric.total_active_records,
            total_new_records: 0
          }

          sub_metric_objects = metrics.map do |m|
            metric_model = METRICS_TO_MODEL[m]
            presenter = (PRESENTER_BASE + m.camelize).constantize

            {metric: m, models: metric_model.created_on(metric.day).map(&presenter).flatten}
          end

          [base_object, sub_metric_objects]
        end

        metrics_information.map(&MetricsApi::V1::Presenters::ApiResponse)
      end
    end
  end
end
