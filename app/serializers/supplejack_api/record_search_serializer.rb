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

    attributes :per_page, :page, :request_url


    hash[:result_count] = object.total
    hash[:results] = records_serialized_array
    hash[:per_page] = object.per_page
    hash[:page] = object.page
    hash[:request_url] = object.request_url
    hash[:solr_request_params] = object.solr_request_params if object.solr_request_params
    hash[:warnings] = object.warnings if object.warnings.present?
    hash[:suggestion] = object.collation if object.options[:suggest]



    # RecordSchema.groups.keys.each do |group|
    #   define_method("#{group}?") do
    #     return false unless options[:groups].try(:any?)
    #     options[:groups].include?(group)
    #   end
    # end
    #
    # def json_facets
    #   facets = {}
    #   object.facets.map do |facet|
    #     rows = {}
    #     facet.rows.each do |row|
    #       rows[row.value] = row.count
    #     end
    #
    #     facets.merge!(facet.name => rows)
    #   end
    #   facets
    # end
    #
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
    #
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
    # def to_xml(*args)
    #   hash = serializable_hash
    #   hash[:facets] = xml_facets
    #
    #   options = {}
    #   options = args.first.merge(root: :search) if args.first.is_a?(Hash)
    #
    #   hash.to_xml(options)
    # end
  end
end
