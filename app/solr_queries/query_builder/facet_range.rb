module QueryBuilder
  class FacetRange < Base
    attr_reader :facet_range, :facet_range_end, :facet_range_start, :facet_range_interval
    
    def initialize(search, facet_range, facet_range_start, facet_range_end, facet_range_interval)
      super(search)

      @facet_range = facet_range
      @facet_range_start = facet_range_start
      @facet_range_end = facet_range_end
      @facet_range_interval = facet_range_interval
    end

    def call
      super

      return search if facet_range_params_missing?

      search.build do
        # # facet @facet_range, :range => @facet_range_start..@facet_range_end, :range_interval => @facet_range_interval

        # facet 'year_dr', range: 2004..2024, range_interval: 1
        
        adjust_solr_params do |params|
          params['facet.range'] = 'year_dr'
          params['facet.range.start'] = '2006-01-01T00:00:00Z'
          params['facet.range.end'] = '2024-01-01T00:00:00Z'
          params['facet.range.gap'] = '+5YEAR'
          params['facet.range.include'] = 'edge'
          params['facet'] = true
        end
      end
    end

    private

    def facet_range_params_missing?
      [facet_range, facet_range_start, facet_range_end, facet_range_interval].any?(&:blank?)
    end
  end
end