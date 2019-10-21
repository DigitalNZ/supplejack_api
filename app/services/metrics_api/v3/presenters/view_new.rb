# frozen_string_literal: true

module MetricsApi
  module V3
    module Presenters
      # Presents a +SupplejackApi::UsageMetrics+ ready to be returned via the API
      class ViewNew
        def initialize(metric)
          @m = metric
        end

        def to_json(*_args)
          {
            id: @m.record_field_value,
            searches: @m.searches,
            record_page_views: @m.gets,
            user_set_views: @m.user_set_views,
            total_views: @m.total_views,
            records_added_to_user_sets: @m.records_added_to_user_sets
          }
        end

        def self.to_proc
          ->(metric) { new(metric).to_json }
        end
      end
    end
  end
end
