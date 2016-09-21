# frozen_string_literal: true
module MetricsApi
  module V3
    module Endpoints
      # Facets endpoint. Returns a list of display_collection names
      class Facets
        attr_reader :primary_key

        # All endpoints take in a params hash, this endpoint has no params however
        def initialize(*)
          # TODO: maybe this should be a global metrics config? There are now 3+ locations you would need
          # to update the primary key for metrics
          @primary_key = 'display_collection'
        end

        # TODO: Better way of collecting display_collection names
        def call
          SupplejackApi::FacetsHelper.get_list_of_facet_values(primary_key)
        end
      end
    end
  end
end
