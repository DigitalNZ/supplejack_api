# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module FacetsSerializer
      extend ActiveSupport::Concern

      included do
        attribute :facets do
          if xml?
            xml_facets
          else
            json_facets
          end
        end

        attribute :facet_pivots, if: -> { facet_pivots? } do
          if xml?
            xml_facet_pivots
          else
            json_facet_pivots
          end
        end

        attribute :facet_ranges, if: -> { facet_ranges? } do
          json_facet_ranges unless xml?
        end

        def xml?
          instance_options[:request_format] == 'xml'
        end

        private

        # This is because the structure of XML Facets and JSON facets are different.

        def xml_facets
          object.facets.each_with_object([]) do |facet, facets|
            values = facet.rows.map do |row|
              { name: row.value, count: row.count }
            end

            facets << { name: facet.name.to_s.gsub('_str', ''), values: }
          end
        end

        def json_facets
          object.facets.each_with_object({}) do |facet, facets|
            rows = facet.rows.each_with_object({}) do |row, hash|
              hash[row.value] = row.count
            end

            facets[facet.name] = rows

            facets[facet.name.to_s.gsub('_str', '')] = facets.delete(facet.name) if facet.name.to_s.include? '_str'
          end
        end

        # This is because the structure of XML Facets and JSON facets are different.

        def facet_pivots?
          # TODO: fix, this is due to Sunspot::Rails::StubSessionProxy::Search not supporting facet_response
          return false if object.try(:facet_response).blank? && Rails.env.test?

          return false if object&.facet_response.blank?

          object.facet_response['facet_pivot'].present?
        end

        def xml_facet_pivots
          facet_pivots = []

          response = object.facet_response['facet_pivot']
          response.each_with_object({}) do |_facet, _facets|
            response.keys.map do |key|
              values = response[key].map { |row| { name: row['value'], count: row['count'] } }
              facet_pivots << { name: key, values: }
            end
          end

          facet_pivots
        end

        def json_facet_pivots
          facet_pivots = {}

          response = object.facet_response['facet_pivot']
          response.each_key do |key|
            rows = []
            response[key].each do |row|
              hash = {}
              hash['field'] = row['field']
              hash['value'] = row['value']
              hash['count'] = row['count']
              hash['pivot'] = row['pivot'] if row['pivot'].present?

              rows.push(hash)
            end

            facet_pivots[key] = rows
          end

          facet_pivots
        end

        def facet_ranges?
          return false if object.try(:facet_response).blank? && Rails.env.test?

          return false if object&.facet_response.blank?

          object.facet_response['facet_ranges'].present?
        end

        def json_facet_ranges
          object.facet_response['facet_ranges'].each_with_object({}) do |(_facet, values), facet_ranges|
            values['counts'].each_slice(2) do |key, value|
              facet_ranges[key] = value
            end
          end
        end
      end
    end
  end
end
