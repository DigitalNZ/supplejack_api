# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/collection_summary_metric.rb
  class CollectionMetric
    include Mongoid::Document

    field :d, as: :date,                               type: Date,    default: Time.zone.now.utc
    field :dc, as: :display_collection,                type: String
    field :s, as: :searches,                           type: Integer, default: 0
    field :rpv, as: :record_page_views,                type: Integer, default: 0
    field :usetv, as: :user_set_views,                 type: Integer, default: 0
    field :ustoryv, as: :user_story_views,             type: Integer, default: 0
    field :tv, as: :total_views,                       type: Integer, default: 0
    field :ratus, as: :records_added_to_user_sets,     type: Integer, default: 0
    field :ratust, as: :records_added_to_user_stories, type: Integer, default: 0
    field :tsc, as: :total_source_clickthroughs,       type: Integer, default: 0

    validates :date, presence: true
    validates :display_collection, presence: true
    validates :display_collection, uniqueness: { scope: :date }

    before_save do |collection|
      self.total_views = (
        collection.searches +
        collection.record_page_views +
        collection.user_set_views +
        collection.user_story_views
      )
    end

    def self.spawn
      return unless SupplejackApi.config.log_metrics == true
      dates = SupplejackApi::RecordMetric.all.map(&:date).uniq

      dates.each do |date|
        collections = SupplejackApi::RecordMetric.where(date: date).map(&:display_collection).uniq

        collections.each do |collection|
          find_or_create_by(date: date, display_collection: collection).inc(
            searches: record_metric(date, collection).sum(:appeared_in_searches),
            record_page_views: record_metric(date, collection).sum(:page_views),
            user_set_views: record_metric(date, collection).sum(:user_set_views),
            user_story_views: record_metric(date, collection).sum(:user_story_views),
            records_added_to_user_sets: record_metric(date, collection).sum(:added_to_user_sets),
            records_added_to_user_stories: record_metric(date, collection).sum(:added_to_user_stories),
            total_source_clickthroughs: record_metric(date, collection).sum(:source_clickthroughs)
          ).save!
        end
      end
    end

    def self.record_metric(date, display_collection)
      SupplejackApi::RecordMetric.where(date: date, display_collection: display_collection)
    end
  end
end
