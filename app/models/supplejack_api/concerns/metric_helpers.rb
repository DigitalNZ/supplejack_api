# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module MetricHelpers
      extend ActiveSupport::Concern

      module ClassMethods
        # produce a logging prefix matching the original style in the model files
        # e.g. "TopMetric" -> "TOP METRIC", "TopCollectionMetric" -> "TOP COLLECTION METRIC"
        def log_prefix
          klass = name.to_s.split('::').last
          klass.gsub(/([a-z\d])([A-Z])/, '\1 \2').tr('_', ' ').upcase
        end

        # Fetch distinct dates for RecordMetric where the given processed flag is false
        def record_metrics_dates_between_for(processed_field, date_range)
          logger.info("#{log_prefix}: Fetching dates for #{processed_field}")
          dates = SupplejackApi::RecordMetric
                  .where(date: date_range, processed_field => false)
                  .distinct(:date)
          logger.info("#{log_prefix}: Processing dates: #{dates}")
          dates
        end

        # Mark all RecordMetric rows for a given date as processed using the given flag
        def stamp_record_metrics_for(processed_field, date)
          logger.info("#{log_prefix}: Stamping all records on #{date} for #{processed_field}")
          SupplejackApi::RecordMetric
            .where(date:, processed_field => false)
            .update_all(processed_field => true)
          logger.info("#{log_prefix}: Stamped all records on: #{date} for #{processed_field}")
        end
      end
    end
  end
end
