module SupplejackApi
  # app/models/supplejack_api/top_collection_metric.rb
  class TopCollectionMetric
    include Mongoid::Document

    METRICS = %i[
      page_views
      user_set_views
      user_story_views
      added_to_user_sets
      source_clickthroughs
      appeared_in_searches
      added_to_user_stories
    ].freeze


    field :d, as: :date,               type: Date, default: Time.current.utc
    field :m, as: :metric,             type: String
    field :r, as: :results,            type: Hash
    field :c, as: :display_collection, type: String

    validates :date, presence: true
    validates :metric, presence: true
    validates :metric, uniqueness: { :scope => [:date, :display_collection] }

    def self.spawn
      return unless SupplejackApi.config.log_metrics == true

      display_collections = SupplejackApi::RecordMetric.where(:date.lt => Time.zone.now.beginning_of_day, processed_by_top_collection_metrics: false)
                                                       .map(&:display_collection).uniq.compact

      dates = SupplejackApi::RecordMetric.where(:date.lt => Time.zone.now.beginning_of_day).map(&:date).uniq

      dates.each do |date|
        METRICS.each do |metric|
          display_collections.each do |dc|
            record_metrics = record_metrics_to_be_processed(date, metric, dc)

            results = record_metrics.each_with_object({}) do |record, hash|
              hash[record.record_id.to_s] = record.send(metric)
            end

            top_collection_metric = find_or_create_by(
              date: date,
              metric: metric,
              display_collection: dc
            )

            if top_collection_metric.results.blank?
              top_collection_metric.update(results: results)
            else
              merged_results = top_collection_metric.results.merge(results) { |_key, a, b| a + b }
              merged_results = merged_results.sort_by { |_k, v| -v }.first(200).to_h

              top_collection_metric.update(results: merged_results)
            end
          end
        end
        stamp_record_metrics(date)
      end
    end

    def self.record_metrics_to_be_processed(date, metric, display_collection)
      SupplejackApi::RecordMetric.where(
        date: date,
        display_collection: display_collection,
        :processed_by_top_collection_metrics.in => [nil, '', false]
      ).order_by(metric => 'desc').limit(200)
    end

    def self.stamp_record_metrics(date)
      SupplejackApi::RecordMetric.where(date: date).update_all(processed_by_top_collection_metrics: true)
    end
  end
end
