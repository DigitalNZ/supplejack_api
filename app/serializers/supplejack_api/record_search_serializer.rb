# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RecordSearchSerializer < ActiveModel::Serializer
    attribute :result_count do
      object.total
    end

    attribute :results do
      options = { fields: instance_options[:record_fields] }
      ActiveModelSerializers::SerializableResource.new(object.results, options)
    end

    attributes :per_page, :page, :request_url
    attribute :solr_request_params, if: -> { object.solr_request_params }
    attribute :warnings, if: -> { object.warnings.present? }
    attribute :facets do
      json_facets
    end

    private

    def json_facets
      object.facets.each_with_object({}) do |facet, facets|
        rows = facet.rows.each_with_object({}) do |row, hash|
          hash[row.value] = row.count
        end

        facets[facet.name] = rows
      end
    end

    # TODO jsonp?
    # def to_json(options = {})
    #   rendered_json = as_json(options).to_json
    #   rendered_json = "#{object.jsonp}(#{rendered_json})" if object.jsonp
    #   rendered_json
    # end
    #
    # def as_json(_options = {})
    #   hash = { search: serializable_hash }
    #   hash[:search][:facets] = json_facets
    #   hash
    # end
    #
    # TODO XML?
    # def to_xml(*args)
    #   hash = serializable_hash
    #   hash[:facets] = xml_facets
    #
    #   options = {}
    #   options = args.first.merge(root: :search) if args.first.is_a?(Hash)
    #
    #   hash.to_xml(options)
    # end
    # def xml_facets
    #   facets = []
    #   object.facets.map do |facet|
    #     values = facet.rows.map do |row|
    #       { name: row.value, count: row.count }
    #     end
    #     facets << { name: facet.name.to_s, values: values }
    #   end
    #   facets
    # end
  end
end
