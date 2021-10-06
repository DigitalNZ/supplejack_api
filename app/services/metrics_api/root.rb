# frozen_string_literal: true

module MetricsApi
  class Root
    attr_accessor :facets, :start_date, :end_date, :metrics

    # Mapping of metric names to the model that represents that metric
    METRICS_TO_MODEL = {
      'record' => SupplejackApi::FacetedMetrics,
      'view' => SupplejackApi::CollectionMetric,
      'top_records' => SupplejackApi::TopCollectionMetric
    }.freeze
    # Mapping of metrics to the field on it's respective model that contains
    # the value to filter against
    METRIC_TO_MODEL_KEY = {
      'record' => :name,
      'view' => :display_collection,
      'top_records' => :display_collection
    }.freeze
    # Facet limit to return in response
    MAX_FACETS = 10

    def initialize(params)
      @facets = parse_csv_param(params[:facets])
      @start_date = SupplejackApi::MetricsHelper.start_date_with(params[:start_date])
      @end_date = SupplejackApi::MetricsHelper.end_date_with(params[:end_date])

      # Do we need to pass these vales. We only collect metrics for record and view?
      @metrics = parse_csv_param(params[:metrics]) || %w[record view]
    end

    def call
      # TODO: Figure out a nicer way of handling error responses
      if facets.blank?
        return {
          exception: {
            status: 400,
            message: 'facets parameter is required'
          }
        }
      end

      if facets.size > MAX_FACETS
        return {
          exception: {
            status: 400,
            message: "Only up to #{MAX_FACETS} may be requested at once"
          }
        }
      end

      metrics_models = metrics.map(&method(:metric_to_model_bundle))
      filtered_models = metrics_models.map(&method(:filter_model_bundle))
      models_grouped_by_date = filtered_models.map(&method(:group_models_in_bundle_by_date))

      MetricsApi::Presenters::ExtendedMetadata.new(models_grouped_by_date, start_date, end_date).to_json
    end

    private

    def metric_to_model_bundle(metric)
      model = METRICS_TO_MODEL[metric]

      Rails.logger.info "METRICS TEST model: #{model}"
      Rails.logger.info "METRICS TEST dates: #{start_date} | #{end_date}"
      Rails.logger.info "METRICS TEST @dates: #{@start_date} | #{@end_date}"
      Rails.logger.info "METRICS TEST date classes: #{start_date.to_date} | #{end_date.to_date}"

      models_in_range = model.created_between(start_date, end_date).to_a

      { metric: metric, models: models_in_range.flatten }
    end

    def filter_model_bundle(model_bundle)
      metric = model_bundle[:metric]
      key = METRIC_TO_MODEL_KEY[metric]

      models_to_keep = model_bundle[:models].select do |model|
        facets.include? model.send(key)
      end

      { metric: metric, models: models_to_keep }
    end

    def group_models_in_bundle_by_date(model_bundle)
      metric = model_bundle[:metric]
      models = model_bundle[:models]

      { metric: metric, models: models.group_by { |m| m.date.to_date } }
    end

    # Converts csv formatted parameter to an array
    #
    # @param param [String] CSV string
    # @return [Array<String>] split CSV
    def parse_csv_param(param)
      return nil if param.blank?

      param.split(',').map(&:strip)
    end
  end
end
