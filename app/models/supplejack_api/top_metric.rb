# frozen_string_literal: true

##
# The purpose of this metric is to store the top 200 records for page_views,
# user_set_views, user_story_views, added_to_user_sets, source_clickthroughs,
# appeared_in_searches, added_to_user_sets for each day.
#
# The results are stored as a hash of record_id => metric count
#

module SupplejackApi
  # app/models/supplejack_api/top_metric.rb
  class TopMetric
    include Mongoid::Document
    include SupplejackApi::Concerns::QueryableByDate
    include SupplejackApi::Concerns::MetricHelpers

    METRICS = %i[
      page_views
      user_set_views
      user_story_views
      added_to_user_sets
      source_clickthroughs
      appeared_in_searches
      added_to_user_stories
    ].freeze

    field :d, as: :date,    type: Date, default: Time.now.utc
    field :m, as: :metric,  type: String
    field :r, as: :results, type: Hash

    validates :date, presence: true
    validates :metric, presence: true
    validates :metric, uniqueness: { scope: :date }

    index({ d: 1, m: 1 }, background: true)

    def self.spawn(date_range = (Time.zone.at(0).utc..Time.now.yesterday.utc.beginning_of_day))
      return unless SupplejackApi.config.log_metrics == true

      record_metrics_dates_between(date_range).each do |date|
        METRICS.each do |metric|
          record_metrics = record_metrics_to_be_processed(date, metric)
          results = record_metrics.each_with_object({}) do |record, hash|
            hash[record.record_id.to_s] = record.send(metric)
          end

          next if results.empty?

          top_metric = find_or_create_by(date:, metric:)
          existing_results = top_metric.results

          if existing_results.blank?
            top_metric.update(results:)
          else
            merged_results = existing_results.merge(results) { |_key, existing, incoming| existing + incoming }
            merged_results = merged_results.sort_by { |_k, value| -value }.first(200).to_h

            top_metric.update(results: merged_results)
          end
        end

        stamp_record_metrics(date)
      end
    end

    def self.record_metrics_to_be_processed(date, metric)
      logger.info("TOP METRIC: Gathering records to be processed: #{date} #{metric}")
      SupplejackApi::RecordMetric.where(
        date:,
        metric.ne => 0,
        processed_by_top_metrics: false
      ).order_by(metric => 'desc').limit(200)
    end

    def self.record_metrics_dates_between(date_range)
      record_metrics_dates_between_for(:processed_by_top_metrics, date_range)
    end

    def self.stamp_record_metrics(date)
      stamp_record_metrics_for(:processed_by_top_metrics, date)
    end
  end
end
