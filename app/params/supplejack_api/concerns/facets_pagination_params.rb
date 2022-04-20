# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module FacetsPaginationParams
      attr_reader :facets_page, :facets_per_page, :facets_offset

      private

      def init_facets_pagination(facets_page: 1, facets_per_page: 10, **_)
        @facets_page = integer_param(:facets_page, facets_page.to_i)
        @facets_per_page = integer_param(:facets_per_page, facets_per_page.to_i)
        @facets_offset = (@facets_page * @facets_per_page) - @facets_per_page
        @facets_offset = @facets_offset.negative? ? 0 : @facets_offset
      end
    end
  end
end
