module MetricsApi
  module V1
    module Presenters
      class DisplayCollection

        def initialize(daily_item_metric)
          @m = daily_item_metric
        end

        def to_json
          @m.display_collection_metrics.map(&method(:display_collection_to_json))
        end

        def display_collection_to_json(dc_metric)
          {
            id: dc_metric.name,
            total_active_records: dc_metric.total_active_records,
            total_new_records: dc_metric.total_new_records,
            category_counts: dc_metric.category_counts,
            copyright_counts: dc_metric.copyright_counts
          }
        end

        def self.to_proc
          ->(metric){self.new(metric).to_json}
        end
      end
    end
  end
end
