# frozen_string_literal: true

module QueryBuilder
  # Facet Queries
  #
  # The facet query parameter should have the following format:
  #
  #   facet_query: {images: {"creator" => "all"}, headings: {"record_type" => 1}}
  #
  # - Each key in the top level hash will be the name of each facet row returned.
  # - Each value in the top level hash is a hash similar with all the restrictions
  class FacetRow < Base
    attr_reader :facet_query

    def initialize(search, facet_query)
      super(search)

      @facet_query = facet_query
    end

    def call
      super
      return search if facet_query.blank?

      search.build do
        facet(:counts) do
          facet_query.each_pair do |row_name, filters_hash|
            row(row_name.to_s) do
              filters_hash.each_pair do |filter, value|
                if value == 'all'
                  without(filter.to_sym, nil)
                elsif filter =~ /-(.+)/
                  without(Regexp.last_match(1).to_sym, this.cast_param(filter, value))
                elsif value.is_a?(Array)
                  with(filter.to_sym).all_of(value)
                else
                  with(filter.to_sym, this.cast_param(filter, value))
                end
              end
            end
          end
        end
      end
    end
  end
end
