# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/top_metric.rb
  class TopMetric
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

    field :d, as: :date,    type: Date, default: Time.zone.today
    field :m, as: :metric,  type: String
    field :r, as: :results, type: Hash

    validates :date, presence: true
    validates :metric, presence: true
    validates :metric, uniqueness: { scope: :date }

    def self.spawn
      return unless SupplejackApi.config.log_metrics == true
      dates = SupplejackApi::RecordMetric.all.map(&:date).uniq

      dates.each do |date|
        METRICS.each do |metric|
          results = results(date, metric).each_with_object({}) do |record, hash|
            hash[record.record_id] = record.send(metric)
          end

          create(
            date: date,
            metric: metric,
            results: results
          )
        end
      end
    end

    def self.results(date, metric)
      SupplejackApi::RecordMetric.where(date: date).limit(200).sort_by(&metric).reverse
    end
  end
end
