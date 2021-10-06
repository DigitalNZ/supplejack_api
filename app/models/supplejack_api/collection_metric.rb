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

                                # 1970-01-01 00:00:00 UTC..2021-10-05 00:00:00 UTC
    def self.spawn(date_range = (Time.at(0).utc..Time.now.yesterday.utc.beginning_of_day))
      # could be date_range = (Date.today - 30..Date.today)
      return unless SupplejackApi.config.log_metrics == true

      # Slow query - about 2 mins
      dates = SupplejackApi::RecordMetric.where(date: date_range).map(&:date).uniq

      # dates cosists of RecordMetric entries with no display_collection so it will be an unnecessary iterations below
      # ie 1970-01-01 00:00:00 UTC..2021-10-05 00:00:00 UTC range has 666 entries in SupplejackApi::RecordMetricdates
      # from Tue, 10 Dec 2019 to Tue, 05 Oct 2021

      # if the above is replaced with dates = SupplejackApi::RecordMetric.where(date: date_range).filter { |i| i.display_collection.present? }.map(&:date).uniq
      # the result is just a single item ie 1 iteration

      # Or use :processed_by_collection_metrics.in => [nil, '', false] here

      dates.each do |date|
        Rails.logger.info("COLLECTION METRICS: Processing date: #{date}")
        # SupplejackApi::RecordMetric has entries with nil display_collection
        collections = SupplejackApi::RecordMetric.where(date: date).map(&:display_collection).uniq

        collections.each do |collection|
          Rails.logger.info("COLLECTION METRICS: Processing collection: #{collection}")
          record_metrics = record_metrics_to_be_processed(date, collection)
          collection_metrics = find_or_create_by(date: date, display_collection: collection).inc(
            searches: record_metrics.sum(:appeared_in_searches),
            record_page_views: record_metrics.sum(:page_views),
            user_set_views: record_metrics.sum(:user_set_views),
            user_story_views: record_metrics.sum(:user_story_views),
            records_added_to_user_sets: record_metrics.sum(:added_to_user_sets),
            records_added_to_user_stories: record_metrics.sum(:added_to_user_stories),
            total_source_clickthroughs: record_metrics.sum(:source_clickthroughs)
          )

          if collection_metrics.save
            record_metrics.update_all(processed_by_collection_metrics: true)
          else
            Rails.logger.error "Unable to summarize record metrics from collection: #{collection} date: #{date}"
          end
        end
        regenerate_all_collection_metrics!(date)
      end
    end

    def self.record_metrics_to_be_processed(date, display_collection)
      Rails.logger.info("COLLECTION METRICS: Gathering records to be processed: #{date} #{display_collection}")
      SupplejackApi::RecordMetric.where(
        date: date,
        display_collection: display_collection,
        :processed_by_collection_metrics.in => [nil, '', false]
      )
    end

    def self.regenerate_all_collection_metrics!(date)
      Rails.logger.info("COLLECTION METRICS: Regenerate all collection metrics #{date}")
      delete_all(date: date, display_collection: 'all')
      all_collections = new(date: date, display_collection: 'all')
      where(date: date, :display_collection.nin => ['all']).find_all do |collection|
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
    end
  end
end

# SupplejackApi::Concerns::RecordsControllerMetrics
# Skip spawning SupplejackApi::RequestMetric when record.record_id & record.display_collection

# SupplejackApi::RecordMetric.count => 729165 investigate why these were deleted

















