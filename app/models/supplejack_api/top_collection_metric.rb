# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/top_collection_metric.rb
  class TopCollectionMetric
    include Mongoid::Document
    include Mongoid::Timestamps
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

    field :d, as: :date,               type: Date, default: Time.now.utc
    field :m, as: :metric,             type: String
    field :r, as: :results,            type: Hash
    field :c, as: :display_collection, type: String

    validates :date, presence: true
    validates :metric, presence: true
    validates :metric, uniqueness: { scope: %i[date display_collection] }

    def self.spawn(date_range = (Time.zone.at(0).utc..Time.now.utc.beginning_of_day))
      return unless SupplejackApi.config.log_metrics == true

      metrics = []

      dates = SupplejackApi::RecordMetric.limit(100_000).where(date: date_range).map(&:date).uniq
      Rails.logger.info("TOP COLLCETION METRIC: processing dates: #{dates}")

      dates.each do |date|
        display_collections(date).each do |dc|
          METRICS.each do |metric|
            record_metrics = record_metrics_to_be_processed(date, metric, dc)

            results = calculate_results(record_metrics, metric)

            # If there are no results for a metric, date, and display collection
            # Skip to the next metric
            next if results.select { |_key, value| value.positive? }.empty?

            top_collection_metric = find_or_create_top_collection_metric(date, metric, dc)
            update_top_collection_metric(top_collection_metric, results)
            metrics.push(top_collection_metric)
          end
        end
        Rails.logger.info("TOP COLLCETION METRIC: Stampping all records on #{date}")
        stamp_record_metrics(date)
      end

      metrics
    end

    def self.display_collections(date)
      Rails.logger.info("TOP COLLCETION METRIC: Finding all display collections on #{date}")
      SupplejackApi::RecordMetric.where(
        date: date,
        :processed_by_top_collection_metrics.in => [nil, '', false]
      ).map(&:display_collection).uniq
    end

    def self.calculate_results(record_metrics, metric)
      record_metrics.each_with_object({}) do |record, hash|
        record_metric_count = record.send(metric)
        hash[record.record_id.to_s] = record_metric_count if record_metric_count.positive?
      end
    end

    def self.update_top_collection_metric(top_collection_metric, results)
      if top_collection_metric.results.blank?
        top_collection_metric.update(results: results)
      else
        merged_results = top_collection_metric.results.merge(results) { |_key, a, b| a + b }
        merged_results = merged_results.sort_by { |_k, v| -v }.first(200).to_h

        top_collection_metric.update(results: merged_results)
      end

      top_collection_metric
    end

    def self.find_or_create_top_collection_metric(date, metric, display_collection)
      top_collection_metric = find_or_create_by(
        date: date,
        metric: metric,
        display_collection: display_collection
      )

      top_collection_metric
    end

    def self.record_metrics_to_be_processed(date, metric, display_collection)
      # rubocop:disable Metrics/LineLength
      Rails.logger.info("TOP COLLCETION METRIC: Gathering top 200 records to be processed #{date}, #{metric}, #{display_collection}")
      # rubocop:enable Metrics/LineLength
      SupplejackApi::RecordMetric.where(
        date: date,
        metric.ne => 0,
        display_collection: display_collection,
        :processed_by_top_collection_metrics.in => [nil, '', false]
      ).order_by(metric => 'desc').limit(200)
    end

    def self.stamp_record_metrics(date)
      SupplejackApi::RecordMetric.where(date: date).update_all(processed_by_top_collection_metrics: true)
    end
  end
end
