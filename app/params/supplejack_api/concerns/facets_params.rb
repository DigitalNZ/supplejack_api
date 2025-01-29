# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module FacetsParams
      attr_reader :facets, :facet_pivots, :facet_query, :facet_missing

      private

      def init_facets(facets: '', facet_query: {}, facet_pivots: '', exclude_filters_from_facets: 'false', facet_missing: false, **_)
        @facets = facets_param(facets)
        @facet_query = facet_query
        @exclude_filters_from_facets = exclude_filters_from_facets == 'true'
        @facet_pivots = facet_pivots_param(facet_pivots)
        @facet_missing = facet_missing
      end

      # Return an array of valid facets
      # It will remove any invalid facets in order to avoid Solr errors
      #
      def facets_param(facets_str)
        facets_list = facets_str.split(',').map { |f| f.strip.to_sym }
        facets_list.keep_if { |f| model_class.valid_facets.include?(f) }

        # This is to prevent users from requesting integer and date fields as facets
        # because we do not have docValues built up for these fields faceting does not work.
        # We do not have docValues because we are experiencing an issue with the facet counts being wrong
        # between different Solr replicas.
        str_facets = %i[integer datetime]
        facets_list.map do |facet|
          if str_facets.include?(schema_class.fields[facet].type)
            "#{facet}_str".to_sym
          else
            facet
          end
        end
      end

      def facet_pivots_param(facet_pivots_str)
        return [] if facet_pivots_str.blank?

        facet_pivots_str.split(',').map do |field|
          field_facet = Sunspot.search(model_class) do
            json_facet(field.to_sym)
          end.facets.first

          field_facet.instance_eval('@field', __FILE__, __LINE__).indexed_name
        rescue Sunspot::UnrecognizedFieldError
          nil
        end.compact.join(',')
      end
    end
  end
end
