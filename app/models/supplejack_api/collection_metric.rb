# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/collection_summary_metric.rb
  class CollectionMetric
    include Mongoid::Document
    include Mongoid::Timestamps
    include SupplejackApi::Concerns::QueryableByDate

    field :d, as: :date,                               type: Date,    default: Time.now.utc
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

    def self.spawn(date_range = (Time.zone.at(0).utc..Time.now.yesterday.utc.beginning_of_day))
      return unless SupplejackApi.config.log_metrics == true

      record_metrics_dates_between(date_range).each do |date|
        Rails.logger.info("COLLECTION METRICS: Processing date: #{date}")
        display_collections = SupplejackApi::RecordMetric
                              .where(date:, processed_by_collection_metrics: { '$ne' => true })
                              .distinct(:display_collection)

        display_collections.each do |display_collection|
          Rails.logger.info("COLLECTION METRICS: Processing collection: #{display_collection}")
          record_metrics = record_metrics_to_be_processed(date, display_collection)

          if update_collection_metrics(record_metrics, date, display_collection)
            record_metrics.update_all(processed_by_collection_metrics: true)
          else
            Rails.logger.error "Unable to summarize record metrics from collection: #{collection} date: #{date}"
          end
        end
        regenerate_all_collection_metrics!(date)
      end
    end

    def self.update_collection_metrics(record_metrics, date, display_collection)
      collection_metrics = find_or_create_by(date:, display_collection:).inc(
        searches: record_metrics.sum(:appeared_in_searches),
        record_page_views: record_metrics.sum(:page_views),
        user_set_views: record_metrics.sum(:user_set_views),
        user_story_views: record_metrics.sum(:user_story_views),
        records_added_to_user_sets: record_metrics.sum(:added_to_user_sets),
        records_added_to_user_stories: record_metrics.sum(:added_to_user_stories),
        total_source_clickthroughs: record_metrics.sum(:source_clickthroughs)
      )

      collection_metrics.save
    end

    def self.record_metrics_to_be_processed(date, display_collection)
      Rails.logger.info("COLLECTION METRICS: Gathering records to be processed: #{date} #{display_collection}")
      SupplejackApi::RecordMetric.where(
        date:,
        display_collection:,
        processed_by_collection_metrics: { '$ne' => true }
      )
    end

    def self.regenerate_all_collection_metrics!(date)
      Rails.logger.info("COLLECTION METRICS: Regenerate all collection metrics #{date}")
      delete_all(date:, display_collection: 'all')
      Rails.logger.info('COLLECTION METRICS: deleted_all')
      all_collections = new(date:, display_collection: 'all')
      where(date:, :display_collection.nin => ['all']).find_all do |collection|
        all_collections.inc(
          searches: collection.searches,
          record_page_views: collection.record_page_views,
          user_set_views: collection.user_set_views,
          user_story_views: collection.user_story_views,
          records_added_to_user_sets: collection.records_added_to_user_sets,
          records_added_to_user_stories: collection.records_added_to_user_stories,
          total_source_clickthroughs: collection.total_source_clickthroughs
        ).save!
      end
      Rails.logger.info('COLLECTION METRICS: saved')
    end

    def self.record_metrics_dates_between(date_range)
      Rails.logger.info('COLLECTION METRIC: fetching dates')
      dates = SupplejackApi::RecordMetric
              .where(date: date_range, processed_by_collection_metrics: { '$ne' => true })
              .hint({ date: 1 })
              .distinct(:date)
      Rails.logger.info("COLLECTION METRIC: processing dates: #{dates}")

      dates
    end
  end
end
