# frozen_string_literal: true

module MetricsApi
  module V3
    module Presenters
      # Presents a +SupplejackApi::TopCollectionMetric+ ready to be returned via the API
      class TopRecords
        def initialize(metric)
          @m = metric
        end

        def to_json
          {
            id: @m.display_collection,
            page_views: SupplejackApi::TopCollectionMetric.find_by(date: @m.date.to_time.utc, metric: 'page_views', display_collection: @m.display_collection),
            user_set_views: SupplejackApi::TopCollectionMetric.find_by(date: @m.date.to_time.utc, metric: 'user_set_views', display_collection: @m.display_collection),
            user_story_views: SupplejackApi::TopCollectionMetric.find_by(date: @m.date.to_time.utc, metric: 'user_story_views', display_collection: @m.display_collection),
            source_clickthroughs: SupplejackApi::TopCollectionMetric.find_by(date: @m.date.to_time.utc, metric: 'source_clickthroughs', display_collection: @m.display_collection),
            appeared_in_searches: SupplejackApi::TopCollectionMetric.find_by(date: @m.date.to_time.utc, metric: 'appeared_in_searches', display_collection: @m.display_collection),
            added_to_user_stories: SupplejackApi::TopCollectionMetric.find_by(date: @m.date.to_time.utc, metric: 'added_to_user_stories', display_collection: @m.display_collection)
          }
        end

        def self.to_proc
          ->(metric) { new(metric).to_json }
        end
      end
    end
  end
end
