module MetricsApi
  module V1
    module Presenters
      # Presents a +SupplejackApi::UsageMetrics+ ready to be returned via the API
      class Usage

        def initialize(metric)
          @m = metric
        end

        def to_json
          {
            id: @m.record_field_value,
            searches: @m.searches,
            record_page_views: @m.gets,
            user_set_views: @m.user_set_views,
            total: @m.total
          }
        end

        def self.to_proc
          ->(metric){self.new(metric).to_json}
        end
      end
    end
  end
end
