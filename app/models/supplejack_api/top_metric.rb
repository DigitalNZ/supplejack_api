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

          metric = find_or_create_by(date:, metric:)

          if metric.results.blank?
            metric.update(results:)
          else
            merged_results = metric.results.merge(results) { |_key, a, b| a + b }
            merged_results = merged_results.sort_by { |_k, v| -v }.first(200).to_h

            metric.update(results: merged_results)
          end
        end

        stamp_record_metrics(date)
      end
    end

    def self.record_metrics_to_be_processed(date, metric)
      Rails.logger.info("TOP METRIC: Gathering records to be processed: #{date} #{metric}")
      SupplejackApi::RecordMetric.where(
        date:,
        metric.ne => 0,
        processed_by_top_metrics: { '$ne' => true }
      ).order_by(metric => 'desc').limit(200)
    end

    def self.record_metrics_dates_between(date_range)
      Rails.logger.info('TOP METRIC: fetching dates')
      dates = SupplejackApi::RecordMetric
              .where(date: date_range, processed_by_top_metrics: { '$ne' => true })
              .hint(date: 1)
              .distinct(:date)
      Rails.logger.info("TOP METRIC: processing dates: #{dates}")

      dates
    end

    def self.stamp_record_metrics(date)
      Rails.logger.info("TOP METRIC: Stampping all records on: #{date}")
      SupplejackApi::RecordMetric
        .where(date:, processed_by_top_metrics: { '$ne' => true })
        .hint(date: 1)
        .update_all(processed_by_top_metrics: true)
      Rails.logger.info("TOP METRIC: Stamped all records on: #{date}")
    end
  end
end
