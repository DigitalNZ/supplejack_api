module MetricsApi
  module V1
    module Presenters
      class DisplayCollection

        def initialize(metric)
          @m = metric
        end

        def to_json
          {
            id: @m.name,
            total_active_records: @m.total_active_records,
            total_new_records: @m.total_new_records,
            category_counts: @m.category_counts,
            copyright_counts: @m.copyright_counts
          }
        end

        def self.to_proc
          ->(metric){self.new(metric).to_json}
        end
      end
    end
  end
end
