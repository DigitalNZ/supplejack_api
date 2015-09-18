module MetricsApi
  module V3
    module Endpoints
      class Extended
        include Helpers

        attr_accessor :facets, :start_date, :end_date, :metrics

        # Mapping of metric names to the model that represents that metric
        METRICS_TO_MODEL = {
          'record' => SupplejackApi::FacetedMetrics,
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

        def initialize(params)
          @facets = parse_csv_param(params[:facets])
          @start_date = parse_date_param(params[:start_date]) || Date.yesterday
          @end_date = parse_date_param(params[:end_date]) || Date.current
          @metrics = parse_csv_param(params[:metrics]) || ['record', 'view']
        end

        def call
          metrics_models = metrics.map do |metric|
            model = METRICS_TO_MODEL[metric]

            models_in_range = model.created_between(start_date, end_date).to_a

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

          MetricsApi::V3::Presenters::ExtendedMetadata.new(models_grouped_by_date, start_date, end_date).to_json
        end

        private

        # Converts csv formatted parameter to an array
        #
        # @param param [String] CSV string
        # @return [Array<String>] split CSV
        def parse_csv_param(param)
          return nil unless param.present?

          param.split(',').map(&:strip)
        end
      end
    end
  end
end
