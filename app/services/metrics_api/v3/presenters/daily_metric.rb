# frozen_string_literal: true

module MetricsApi
  module V3
    module Presenters
      class DailyMetric
        def initialize(daily_metric)
          @dm = daily_metric
        end

        def to_json(*_args)
          {
            day: @dm.date,
            total_public_sets: @dm.total_public_sets
          }
        end

        def self.to_proc
          ->(metric) { new(metric).to_json }
        end
      end
    end
  end
end
