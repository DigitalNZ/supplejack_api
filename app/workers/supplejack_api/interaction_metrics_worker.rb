# frozen_string_literal: true



module SupplejackApi
  class InteractionMetricsWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'low', retry: false
    class << self
      attr_reader :interaction_updaters
    end

    # Contains list of +InteractionUpdater+ classes to be executed by worker
    @interaction_updaters = []

    # This worker calls all the InteractionUpdater modules, which are now spread across
    # supplejack_api and dnz api. All these updaters update UsageMetrics, different fields.
    def perform
      self.class.interaction_updaters.each do |interaction_updater|
        models_to_process = interaction_updater.model.all
        models_to_process.delete_all if interaction_updater.process(models_to_process.to_a)
      end
    end

    def self.register_interaction_updater(interaction_updater)
      @interaction_updaters << interaction_updater.new
    end

    # Interface for interaction updaters
    # Interaction updaters are tied to a specific interaction model
    # and know how to turn a list of interaction models into a model
    # that represents a single day of interactions for that model
    #
    # Interaction updaters are registered in config/initializers/interaction_updaters.rb
    class InteractionUpdater
      # Model class that logs interactions for this updater to process
      attr_reader :model

      # Takes in an array of interaction models and converts them into
      # a model that represents days worth of interactions
      #
      # @param models [Array<Any>] list of interaction models to process
      # @return Nothing
      def process(_); end
    end
  end
end
