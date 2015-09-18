module MetricsApi
  module V3
    module Endpoints
      # Facets endpoint. Returns a list of display_collection names
      class Facets
        # All endpoints take in a params hash, this endpoint has no params however
        def initialize(*)
        end

        # TODO: Better way of collecting display_collection names
        def call
          latest_date = SupplejackApi::FacetedMetrics.last.day
          display_collections = SupplejackApi::FacetedMetrics.created_on(latest_date)

          display_collections.map(&:name)
        end
      end
    end
  end
end
