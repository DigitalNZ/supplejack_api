# frozen_string_literal: true

module QueryBuilder
  class FacetPivot < Base
    attr_reader :facet_pivot_list

    def initialize(search, facet_pivot_list)
      super(search)

      @facet_pivot_list = facet_pivot_list
    end

    def call
      super
      return search if facet_pivot_list.blank?

      search.build do
        adjust_solr_params do |params|
          params['facet.pivot'] = facet_pivot_list
          params['facet'] = 'on'
        end
      end
    end
  end
end
