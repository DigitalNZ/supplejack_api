# frozen_string_literal: true

module SupplejackApi
  class SearchSerializer < ActiveModel::Serializer
    attribute :result_count do
      object.total
    end

    attribute :results do
      options = { fields: instance_options[:record_fields], include: instance_options[:record_includes] }
      ActiveModelSerializers::SerializableResource.new(object.results, options)
    end

    attributes :per_page, :page, :request_url
    attribute :solr_request_params, if: -> { object.solr_request_params }
    attribute :warnings, if: -> { object.warnings.present? }
    attribute :facets do
      if xml?
        xml_facets
      else
        json_facets
      end
    end

    attribute :facet_pivots do
      if xml?
        xml_facet_pivots
      else
        json_facet_pivots
      end
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

        facets << { name: facet.name.to_s, values: values }
      end
    end

    def json_facets
      object.facets.each_with_object({}) do |facet, facets|
        rows = facet.rows.each_with_object({}) do |row, hash|
          hash[row.value] = row.count
        end

        facets[facet.name] = rows
      end
    end

    # This is because the structure of XML Facets and JSON facets are different.

    def xml_facet_pivots
      object.facet_pivot.each_with_object([]) do |facet_pivot, facet_pivots|
        values = facet_pivot.rows.map do |row|
          { field: row.field, value : row.value, count: row.count }
        end

        facet_pivots << { name: facet_pivot.name.to_s, values: values }
      end
    end

    def json_facet_pivots
      object.facet_pivot.each_with_object({}) do |facet_pivot, facet_pivots|
        rows = facet_pivot.rows.each_with_object({}) do |row, hash|
          hash[row.value] = row.count
        end

        facet_pivots[facet_pivot.name] = rows
      end
    end
  end
end
