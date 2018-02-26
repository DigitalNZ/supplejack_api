# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/collection_summary_metric.rb
  class CollectionSummaryMetric
    include Mongoid::Document

    field :d, as: :date,                           type: Date,    default: Time.zone.today
    field :dc, as: :display_collection,            type: String
    field :s, as: :searches,                       type: Integer, default: 0
    field :rpv, as: :record_page_views,            type: Integer, default: 0
    field :usetv, as: :user_set_views,             type: Integer, default: 0
    field :ustoryv, as: :user_story_views,         type: Integer, default: 0
    field :tv, as: :total_views,                   type: Integer, default: 0
    field :ratus, as: :records_added_to_user_sets, type: Integer, default: 0
    field :tsc, as: :total_source_clickthroughs,   type: Integer, default: 0

    validates :display_collection, presence: true
    validates :display_collection, uniqueness: { scope: :date }

    def self.spawn
      return unless SupplejackApi.config.log_metrics == true
      collections = SupplejackApi::RecordMetric.all.flat_map(&:content_partner).uniq

      collections.map do |collection|
        create(collection: collection)
      end
    end
  end
end
