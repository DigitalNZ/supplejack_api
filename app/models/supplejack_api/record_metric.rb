# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/record_metric.rb
  class RecordMetric
    include Mongoid::Document

    field :date,                  type: Date,    default: Time.current.utc
    field :record_id,             type: Integer
    field :page_views,            type: Integer, default: 0
    field :user_set_views,        type: Integer, default: 0
    field :display_collection,    type: String
    field :user_story_views,      type: Integer, default: 0
    field :added_to_user_sets,    type: Integer, default: 0
    field :source_clickthroughs,  type: Integer, default: 0
    field :appeared_in_searches,  type: Integer, default: 0
    field :added_to_user_stories, type: Integer, default: 0

    validates :record_id, presence: true
    validates :record_id, uniqueness: { scope: :date }

    index({ record_id: 1, display_collection: 1, date: 1 }, background: true)

    def self.spawn(record_id, metrics, display_collection, date = Time.current.utc)
      return unless SupplejackApi.config.log_metrics == true
      find_or_create_by(record_id: record_id, date: date, display_collection: display_collection).inc(metrics)
    end
  end
end



# puts (Benchmark.measure do
#   test.each do |id, details|
#     SupplejackApi::RecordMetric.collection.update_one({ record_id: id, date: Time.now.utc.to_date, display_collection: details['display_collection']}, { '$inc' => details['metrics']}, { upsert: true })
#   end
# end)
