# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/request_metric.rb
  class RequestMetric
    include Mongoid::Document

    field :date,    type: Date,   default: Time.zone.today
    field :records, type: Array,  default: []
    field :metric,  type: String

    validates :records, presence: true
    validates :metric,  presence: true

    def self.spawn(records, metric, date = Time.zone.today)
      return unless SupplejackApi.config.log_metrics == true
      create(records: records, metric: metric, date: date)
    end

    def self.summarize
      return unless SupplejackApi.config.log_metrics == true

      # Split the requests by date
      summarized_metrics = all.group_by(&:date).each_with_object({}) do |(date, metrics), summary|
        uniq_records = metrics.flat_map(&:records).uniq
        summary[date] = {}

        uniq_records.each do |record|
          summary[date][record['record_id']] = {
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

        # Group them by metric
        metrics.group_by(&:metric).each do |metric, results|
          metric_total_records = results.flat_map(&:records)
          metric_uniq_records = metric_total_records.uniq

          # Total the number of records within a date/metric
          metric_uniq_records.map do |record|
            record_id = record['record_id']
            summary[date][record_id]['metrics'][metric] = metric_total_records.count(record)
            summary[date][record_id]['display_collection'] = record['display_collection']
          end
        end
      end

      # Generate Record Metrics
      summarized_metrics.each do |date, record|
        record.each do |id, details|
          RecordMetric.spawn(id, details['metrics'], details['display_collection'], date)
        end
      end

      all.destroy
    end
  end
end
