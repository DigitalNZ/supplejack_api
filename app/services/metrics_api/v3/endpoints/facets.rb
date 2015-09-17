module MetricsApi
  module V3
    module Endpoints
      # Facets endpoint. Returns a list of display_collection names
      class Facets
        # All endpoints take in a params hash, this endpoint has no params however
        def initialize(ignored)
        end

        def call
          display_collections = SupplejackApi::DailyItemMetric.last.display_collection_metrics

          display_collections.map(&:name)
        end
      end
    end
  end
end
