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

        def to_json
          binding.pry
          { @m.metric.to_s: @m.results }
        end

        def self.to_proc
          ->(metric) { new(metric).to_json }
        end
      end
    end
  end
end
