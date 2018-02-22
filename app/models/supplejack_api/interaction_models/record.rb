# frozen_string_literal: true



# This model is a temporary store to log every request to index, show action for a Record
# This data is used by interaction udpaters to create UsageMetric entries and deleted after
module SupplejackApi
  module InteractionModels
    class Record
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: 'record_interactions'

      field :request_type, type: String
      field :log_values,   type: Array

      @field = :display_collection

      # Creates an entry for record search
      def self.create_search(object)
        results = object.results.map(&@field).flatten
        create(request_type: 'search', log_values: results) unless results.empty?
      rescue StandardError => e
        Rails.logger.warn "[RecordInteraction] #{e.message}"
      end

      # Creates an entry for a record view
      def self.create_find(object)
        return if object.nil?
        result = object.send(@field)
        result = [result] unless result.is_a? Array
        create(request_type: 'get', log_values: result) unless result.empty?
      rescue StandardError => e
        Rails.logger.warn "[RecordInteraction] #{e.message}"
      end

      # Creates one Interaction Model that contains set items in a set
      #
      # @param object [SupplejackApi::UserSet]
      def self.create_user_set(object)
        results = []
        unless object.set_items.empty?
          object.set_items.each do |item|
            next if item.record.nil?
            record = SupplejackApi.config.record_class.custom_find(item.record_id)
            if record
              result = record.send(@field)
              results << result if result
            end
          end
        end

        create(request_type: 'user_set', log_values: results.flatten) unless results.empty?
      rescue StandardError => e
        Rails.logger.warn "[RecordInteraction] #{e.message}"
      end
    end
  end
end
