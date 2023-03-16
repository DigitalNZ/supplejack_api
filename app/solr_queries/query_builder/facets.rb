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
  class Facets < Base
    attr_reader :facet_list, :facets_per_page, :facets_offset

    def initialize(search, params)
      super(search)

      @facet_list = params.facets
      @facets_per_page = params.facets_per_page
      @facets_offset = params.facets_offset
    end

    def call
      super
      return search if facet_list.blank?

      search.build do
        facet_list.each do |facet_name|
          facet(facet_name, limit: facets_per_page, offset: facets_offset)

          adjust_solr_params do |params|
            field_definition = RecordSchema.fields[facet_name]

            next if field_definition&.facet_method.blank?

            indexed_name = params[:'facet.field'].find { |facet| facet.include?(facet_name.to_s) }

            params[:"f.#{indexed_name}.facet.method"] = field_definition.facet_method
          end
        end
      end
    end
  end
end
