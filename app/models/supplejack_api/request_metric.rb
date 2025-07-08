# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/request_metric.rb
  class RequestMetric
    include Mongoid::Document

    field :date,    type: Date,   default: Time.now.utc.beginning_of_day
    field :records, type: Array,  default: []
    field :metric,  type: String

    validates :records, presence: true
    validate :records_integrity
    validates :metric,  presence: true

    def records_integrity
      return unless records.any? { |record| record[:record_id].nil? || record[:display_collection].nil? }

      Rails.logger.info('RequestMetric failed the records_integrity check')
      errors.add(:records, 'must contain each a record_id and a display_collection')
    end

    def self.spawn(records, metric, date = Time.now.utc.beginning_of_day)
      return unless SupplejackApi.config.log_metrics == true

      create(records:, metric:, date:)
    end

    # rubocop:disable Metrics/MethodLength
    def self.summarize
      return unless SupplejackApi.config.log_metrics

      Rails.logger.info('Starting summarization of RequestMetrics')
      current_date = nil
      summary = {}

      RequestMetric
        .batch_size(1_000)
        .order_by(date: 1, _id: 1)
        .each do |metric|
          Rails.logger.info("Processing metric for date: #{metric.date}, metric: #{metric.metric}")

          # When we hit a new date, flush the last date’s summaries:
          if current_date && metric.date != current_date
            Rails.logger.info("\nFlushing summary for date: #{current_date}\n")
            flush_summary_for(current_date, summary)
            summary.clear
          end

          current_date = metric.date

          metric.records.each do |rec|
            key = rec['record_id']
            summary[key] ||= {
              metrics: {
                page_views: 0,
                user_set_views: 0,
                user_story_views: 0,
                added_to_user_sets: 0,
                source_clickthroughs: 0,
                appeared_in_searches: 0,
                added_to_user_stories: 0
              },
              display_collection: rec['display_collection']
            }
            summary[key][:metrics][metric.metric.to_sym] += 1
          end

          metric.destroy
        end

      # Flush the last date left in summary
      flush_summary_for(current_date, summary) if current_date
    end
    # rubocop:enable Metrics/MethodLength

    def self.flush_summary_for(date, summary)
      summary.each do |record_id, details|
        RecordMetric.spawn(
          record_id,
          details[:metrics].transform_keys(&:to_s),
          details[:display_collection],
          date
        )
      end
    end
  end
end
