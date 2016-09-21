# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptSerializer < ActiveModel::Serializer
    has_many :source_authorities, serializer: SupplejackApi::SourceAuthoritySerializer
    has_many :records, serializer: SupplejackApi::ConceptRecordSerializer

    ConceptSchema.groups.keys.each do |group|
      define_method("#{group}?") do
        return false unless options[:groups].try(:any?)
        options[:groups].include?(group)
      end
    end

    def serializable_hash
      hash = attributes
      # Create empty context block to add to once we know what fields we have.
      hash['@context'] = {}
      hash['@type'] = object.concept_type
      hash['@id'] = object.site_id

      if default? || verbose?
        groups = (options[:groups] & ConceptSchema.groups.keys) || []
        fields = Set.new

        groups.each do |group|
          fields.merge(ConceptSchema.groups[group].try(:fields)) rescue {}
        end

        fields.each do |field|
          # Doesn't allow the real record id to be overwritten by mongo id
          hash[field] = field == :id ? hash[field] : field_value(field, options)
        end
      end

      include_individual_fields!(hash)
      include_context_fields!(hash)
      include_reverse_fields!(hash) if reverse?
      include!(:source_authorities, node: hash) if source_authorities?
      hash
    end

    def include_context_fields!(hash)
      fields = hash.dup
      fields.keep_if { |field| ConceptSchema.model_fields.include?(field) }
      field_keys = fields.keys

      # Include unstored fields from the Schema
      record_fields = ConceptSchema.model_fields.select { |_key, value| value.try(:store) == false }
      field_keys += record_fields.keys

      hash['@context'] = if options[:inline_context]
                           Concept.build_context(field_keys)
                         else
                           object.context
                         end
      hash
    end

    def include_individual_fields!(hash)
      if options[:fields].present?
        options[:fields].push(:concept_id)
        options[:fields].sort!
        options[:fields].each do |field|
          hash[field] = object.send(field)
        end
      end
      hash
    end

    def include_reverse_fields!(hash)
      hash['@reverse'] = {}
      key = concept.edm_type
      include!(:records, node: hash['@reverse'], key: key)
      hash
    end

    def field_value(field)
      value = if ConceptSchema.fields[field].try(:search_value) && ConceptSchema.fields[field].try(:store) == false
                ConceptSchema.fields[field].search_value.call(object)
              else
                object.public_send(field)
              end

      value = ConceptSchema.fields[field].try(:default_value) if value.nil? rescue nil

      if ConceptSchema.fields[field].try(:date_format)
        value = format_date(value, ConceptSchema.fields[field].try(:date_format))
      end

      value
    end
  end
end
