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
        field_definition = RecordSchema.fields[facet_range.to_sym] 
        return search if field_definition&.solr_name.blank?
        
        adjust_solr_params do |params|
          params['facet.range'] = field_definition.solr_name
          params['facet.range.start'] = SupplejackApi::DateHelper.solr_format(DateTime.new(facet_range_start.to_i))
          params['facet.range.end'] = SupplejackApi::DateHelper.solr_format(DateTime.new(facet_range_end.to_i))
          params['facet.range.gap'] = facet_range_interval
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