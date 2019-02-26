# frozen_string_literal: true

module MetricsApi
  module V3
    module Presenters
      # Presents a +SupplejackApi::TopCollectionMetric+ ready to be returned via the API
      class TopRecords
        def initialize(metric)
          binding.pry
          @m = metric
        end

        # rubocop:disable Metrics/LineLength
        def to_json
          page_views = SupplejackApi::TopCollectionMetric.where(date: @m.date, metric: 'page_views', display_collection: @m.display_collection).exists? ? SupplejackApi::TopCollectionMetric.find_by(date: @m.date, metric: 'page_views', display_collection: @m.display_collection) : nil
          user_set_views = SupplejackApi::TopCollectionMetric.where(date: @m.date, metric: 'user_set_views', display_collection: @m.display_collection).exists? ? SupplejackApi::TopCollectionMetric.find_by(date: @m.date, metric: 'user_set_views', display_collection: @m.display_collection) : nil
          user_story_views = SupplejackApi::TopCollectionMetric.where(date: @m.date, metric: 'user_story_views', display_collection: @m.display_collection).exists? ? SupplejackApi::TopCollectionMetric.find_by(date: @m.date, metric: 'user_story_views', display_collection: @m.display_collection) : nil
          source_clickthroughs = SupplejackApi::TopCollectionMetric.where(date: @m.date, metric: 'source_clickthroughs', display_collection: @m.display_collection).exists? ? SupplejackApi::TopCollectionMetric.find_by(date: @m.date, metric: 'source_clickthroughs', display_collection: @m.display_collection) : nil
          appeared_in_searches = SupplejackApi::TopCollectionMetric.where(date: @m.date, metric: 'appeared_in_searches', display_collection: @m.display_collection).exists? ? SupplejackApi::TopCollectionMetric.find_by(date: @m.date, metric: 'appeared_in_searches', display_collection: @m.display_collection) : nil
          added_to_user_stories = SupplejackApi::TopCollectionMetric.where(date: @m.date, metric: 'added_to_user_stories', display_collection: @m.display_collection).exists? ? SupplejackApi::TopCollectionMetric.find_by(date: @m.date, metric: 'added_to_user_stories', display_collection: @m.display_collection) : nil

          {
            id: @m.display_collection,
            page_views: page_views,
            user_set_views: user_set_views,
            user_story_views: user_story_views,
            source_clickthroughs: source_clickthroughs,
            appeared_in_searches: appeared_in_searches,
            added_to_user_stories: added_to_user_stories
          }.compact
        end
        # rubocop:enable Metrics/LineLength

        def self.to_proc
          ->(metric) { new(metric).to_json }
        end
      end
    end
  end
end
