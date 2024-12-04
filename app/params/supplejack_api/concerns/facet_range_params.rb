# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module FacetRangeParams
      attr_reader :facet_range, :facet_range_start, :facet_range_end, :facet_range_interval

      private

      def init_facet_range(facet_range: nil, facet_range_start: nil, facet_range_end: nil, facet_range_interval: nil,
                           **_)
        @facet_range = facet_range
        @facet_range_start = facet_range_start
        @facet_range_end = facet_range_end
        @facet_range_interval = facet_range_interval
      end
    end
  end
end
