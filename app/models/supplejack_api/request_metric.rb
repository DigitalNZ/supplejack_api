# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/request_metric.rb
  class RequestMetric
    include Mongoid::Document

    field :date,    type: Date,   default: Time.zone.now.beginning_of_day
    field :records, type: Array,  default: []
    field :metric,  type: String

    validates :records, presence: true
    validates :metric,  presence: true

    def self.spawn(records, metric, date = Time.zone.now.beginning_of_day)
      return unless SupplejackApi.config.log_metrics == true
      create(records: records, metric: metric, date: date)
    end

    # rubocop:disable Metrics/MethodLength
    def self.summarize
      return unless SupplejackApi.config.log_metrics == true

      records = all.to_a
      summarized_metrics = records.group_by(&:date).each_with_object({}) do |(date, metrics), summary|
        summary[date] = Hash.new do |hash, key|
          hash[key] = {
            'metrics' => {
              'page_views' => 0,
              'user_set_views' => 0,
              'user_story_views' => 0,
              'added_to_user_sets' => 0,
              'source_clickthroughs' => 0,
              'appeared_in_searches' => 0,
              'added_to_user_stories' => 0
            },
            'display_collection' => 'none'
          }
        end

        metrics.each do |metric|
          metric.records.each do |record|
            summary[date][record['record_id']]['metrics'][metric.metric] += 1
            summary[date][record['record_id']]['display_collection'] = record['display_collection']
          end
        end
      end

      summarized_metrics.each do |date, record|
        record.each do |id, details|
          RecordMetric.spawn(id, details['metrics'], details['display_collection'], date)
        end
      end

      records.map(&:destroy)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
