# frozen_string_literal: true

module QueryBuilder
  class ExcludeFiltersFromFacets < Base
    attr_reader(
      :exclude_filters_from_facets,
      :and_condition,
      :or_condition,
      :facet_list,
      :facets_per_page,
      :facets_offset
    )

    def initialize(search, params)
      super(search)

      @exclude_filters_from_facets = params.exclude_filters_from_facets
      @and_condition = params.and_condition
      @or_condition = params.or_condition
      @facet_list = params.facets
      @facets_per_page = params.facets_per_page
      @facets_offset = params.facets_offset
    end

    def call
      super

      return search unless exclude_filters_from_facets

      search.build do
        or_and_options.slice(*facet_list).each do |facet_name, value|
          facet(
            facet_name.to_sym,
            exclude: QueryBuilder::ExcludeFiltersFromFacets.with_query_for_facet_exclusion(self, facet_name.to_sym, value),
            limit: facets_per_page,
            offset: facets_offset
          )
        end
      end
    end

    def self.with_query_for_facet_exclusion(search_context, facet_name, value)
      # Necessary to pass search_context in order to generate `with` queries
      wildcard_search_term_regex = /(.+)\*$/ # search term ends in *

      if value.is_a?(String) && value =~ wildcard_search_term_regex
        search_context.with(facet_name).starting_with(Regexp.last_match(1))
      elsif value.is_a?(Hash) && value.key?(:or)
        search_context.with(facet_name, value[:or])
      elsif %w[true false].include?(value)
        # If Solr receives the string value 'false',
        # it will convert it into the Boolean true, giving the opposite result
        boolean_value = (value == 'true')

        search_context.with(facet_name, boolean_value)
      else
        # Value is a non-wildcarded string, or an array
        search_context.with(facet_name, value)
      end
    end

    private

    def or_and_options
      or_and_options = {}.merge(and_condition).merge(or_condition).symbolize_keys

      # This is to clean up any valid integer or date facets that have been requested
      # Through the filter options, so that they are treated as strings.
      str_facets = %i[integer datetime]
      converted_string_facets = or_and_options.each_with_object([]) do |(facet_name, _facet_value), array|
        array.push(facet_name) if str_facets.include?(RecordSchema.fields[facet_name.to_sym]&.type)
      end

      converted_string_facets.each do |facet|
        or_and_options["#{facet}_str".to_sym] = or_and_options.delete(facet)
      end

      or_and_options
    end
  end
end
