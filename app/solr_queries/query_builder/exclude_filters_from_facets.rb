# frozen_string_literal: true

module QueryBuilder
  class ExcludeFiltersFromFacets < Base
    attr_reader(
      :exclude_filters_from_facets,
      :and_conditions,
      :or_conditions,
      :facet_list,
      :facets_per_page,
      :facets_offset
    )

    def initialize(
      search,
      exclude_filters_from_facets,
      and_conditions,
      or_conditions,
      facet_list,
      facets_per_page,
      facets_offset
    )
      super(search)

      @exclude_filters_from_facets = exclude_filters_from_facets
      @and_conditions = and_conditions
      @or_conditions = or_conditions
      @facet_list = facet_list
      @facets_per_page = facets_per_page
      @facets_offset = facets_offset
    end

    def call
      super
      return search if exclude_filters_from_facets != 'true'

      or_and_options = {}.merge(and_conditions).merge(or_conditions).symbolize_keys

      # This is to clean up any valid integer or date facets that have been requested
      # Through the filter options, so that they are treated as strings.
      str_facets = %i[integer datetime]
      converted_string_facets = or_and_options.each_with_object([]) do |(facet_name, _facet_value), array|
        array.push(facet_name) if str_facets.include?(RecordSchema.fields[facet_name.to_sym]&.type)
      end

      converted_string_facets.each do |facet|
        or_and_options["#{facet}_str".to_sym] = or_and_options.delete(facet)
      end

      search.build do
        or_and_options.slice(*facet_list).each do |facet_name, value|
          facet(
            facet_name.to_sym,
            exclude: with_query_for_facet_exclusion(self, facet_name.to_sym, value),
            limit: facets_per_page,
            offset: facets_offset
          )
        end
      end
    end

    private

    def with_query_for_facet_exclusion(search_context, facet_name, value)
      # Necessary to pass search_context in order to generate `with` queries
      wildcard_search_term_regex = /(.+)\*$/ # search term ends in *

      if value =~ wildcard_search_term_regex
        search_context.with(facet_name).starting_with(Regexp.last_match(1))
      elsif value.is_a?(Hash) && value.key?(:or)
        search_context.with(facet_name, value[:or])
      else
        # Value is a non-wildcarded string, or an array
        search_context.with(facet_name, value)
      end
    end
  end
end
