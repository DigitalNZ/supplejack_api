module MetricsApi
  module V3
    # API entry point for V3 of the MetricsAPI
    # 
    # It takes in the request parameters and 
    # generates the metrics JSON the API should 
    # respond with
    class Api
      # Base namespace for Presenters, append presenter name to it and call
      # constantize to get presenter instance
      PRESENTER_BASE = "MetricsApi::V3::Presenters::"
      # Mapping of metric names to the model that represents that metric
      METRICS_TO_MODEL = {
        'display_collection' => SupplejackApi::DailyItemMetric,
        'usage' => SupplejackApi::UsageMetrics
      }

      attr_reader :start_date, :end_date, :metrics

      # @param [Hash] params request parameters hash
      # @option params [Date] :start_date (Date.yesterday) start of the range of metrics to retrieve
      # @option params [Date] :end_date (Date.current) end of the range of metrics to retrieve
      # @option params [String] :metrics ('usage,metrics') CSV string of sub metrics to include in response
      def initialize(params)
        @start_date = params[:start_date] || Date.yesterday
        @end_date = params[:end_date] || Date.current
        @metrics = parse_metrics_param(params[:metrics]) || ['usage', 'display_collection']
      end

      # Generates an API response using the parameters passed in when the class is created.
      # This response has already been presented and is ready to deliver to the client
      #
      # @return [Array<Hash>] the generated API response
      def call
        metric_models = SupplejackApi::DailyItemMetric.created_between(start_date, end_date)

        unless metric_models.present?
          return {
            exception: {
              message: 'No metric information was present for the date range you requested',
              status: 404
            }
          }
        end

        metrics_information = metric_models.map do |metric|
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

        metrics_information.map(&MetricsApi::V3::Presenters::ApiResponse)
      end

      private

      # Converts metrics parameter to an array from a CSV
      #
      # @param param [String] CSV metrics string
      # @return [Array<String>] split metrics CSV
      def parse_metrics_param(param)
        return nil unless param.present?

        param.split(',').map(&:strip)
      end
    end
  end
end
