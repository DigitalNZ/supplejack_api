module MetricsApi
  module V3
    module Endpoints
      class Extended
        attr_accessor :facets, :start_date, :end_date, :metrics

        # Mapping of metric names to the model that represents that metric
        METRICS_TO_MODEL = {
          'record' => SupplejackApi::DailyItemMetric,
          'view' => SupplejackApi::UsageMetrics
        }
        # Mapping of metrics to the field on it's respective model that contains
        # the value to filter against
        METRIC_TO_MODEL_KEY = {
          'record' => :name,
          'view' => :record_field_value
        }
        # Mapping of metrics to the field on it's respective model that contains
        # the date the metric is for
        METRIC_TO_MODEL_DATE_KEY = {  
          'record' => :day,
          'view' => :created_at
        }
        # Mapping of metric names to procs that should be called on the
        # metric model after it is retrieved
        POST_RETRIEVE_MODIFIERS = {
          'record' => ->(daily_item_metric) {daily_item_metric.display_collection_metrics}
        }

        def initialize(params)
          @facets = params[:facets]
          @start_date = params[:start_date] || Date.current
          @end_date = params[:end_date] || Date.current
          @metrics = parse_metrics_param(params[:metrics]) || ['record', 'view']
        end

        def call
          metrics_models = metrics.map do |metric|
            model = METRICS_TO_MODEL[metric]
            modifier = POST_RETRIEVE_MODIFIERS[metric]

            models_in_range = model.created_between(start_date, end_date).to_a
            models_in_range.map!(&modifier) if modifier.present?

            {metric: metric, models: models_in_range.flatten}
          end

          filtered_models = metrics_models.map do |metric_models|
            metric = metric_models[:metric]
            key = METRIC_TO_MODEL_KEY[metric]

            models_to_keep = metric_models[:models].select do |model|
              facets.include? model.send(key)
            end

            {metric: metric, models: models_to_keep}
          end

          models_grouped_by_date = filtered_models.map do |model_group|
            metric = model_group[:metric]
            models = model_group[:models]
            date_key = METRIC_TO_MODEL_DATE_KEY[metric]

            {metric: metric, models: models.group_by{|m| m.send(date_key).to_date}}
          end

          MetricsApi::V3::Presenters::ExtendedMetadata.new(models_grouped_by_date).to_json
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
end
