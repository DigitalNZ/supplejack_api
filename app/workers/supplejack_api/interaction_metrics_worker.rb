# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class InteractionMetricsWorker

    # Contains list of +InteractionUpdater+ classes to be executed by worker
    @interaction_updaters = []

    @queue = :usage_metrics

    def self.perform
      @interaction_updaters.each do |interaction_updater|
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
