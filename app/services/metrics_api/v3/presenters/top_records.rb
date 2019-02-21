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
            page_views: @m.page_views,
            user_set_views: @m.user_set_views,
            user_story_views: @m.user_story_views,
            source_clickthroughs: @m.source_clickthroughs,
            appeared_in_searches: @m.appeared_in_searches,
            added_to_user_stories: @m.added_to_user_stories
          }
        end

        def self.to_proc
          ->(metric) { new(metric).to_json }
        end
      end
    end
  end
end
