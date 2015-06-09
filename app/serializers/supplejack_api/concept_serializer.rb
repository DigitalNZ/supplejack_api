# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptSerializer < ActiveModel::Serializer

    has_many :source_authorities

    def source_authorities?
      return false if (options[:groups]).blank?
      return concept.try(options[:groups]).try(:any?)
    end

    def serializable_hash
      hash = attributes
      # Create empty context block to add to once we know what fields we have.
      hash['@context'] = {}
      hash['@type'] = concept.send(:@type)
      hash['@id'] = "#{self.options[:domain]}/concepts/#{concept.concept_id}"

      include!(:source_authorities, :node => hash) if source_authorities?

      include_individual_fields!(hash)
      include_context_fields!(hash)
      hash
    end

    def include_context_fields!(hash)
      fields = hash.dup
      fields.shift

      if self.options[:inline_context] == "true"
        hash['@context'] = build_context(fields.keys)
      else
        hash['@context'] = "#{self.options[:domain]}/schema"
      end
      hash
    end

    def include_individual_fields!(hash)
      if self.options[:fields].present?
        self.options[:fields].each do |field|
          hash[field] = concept.send(field)
        end
      end
      hash
    end

    def build_context(fields)
      context = {}

      namespaces = []

      fields.each do |field|
        namespaces << ConceptSchema.model_fields[field].try(:namespace)
      end

      namespaces.compact.uniq.each do | namespace |
        context[namespace] = ConceptSchema.namespaces[namespace].url
        namespaced_fields(namespace).each do |name, field|
          context[name] = "#{field.namespace}:#{field.namespace_field}" if fields.include?(name) && name != field.namespace
        end
      end

      fields.each do |field|
        context[field] = {}
        namespace = ConceptSchema.model_fields[field].try(:namespace)
        context[field]['@id'] = "#{namespace}:#{field.to_s}"
      end
      context
    end

    def namespaced_fields(namespace)
      ConceptSchema.fields.select { |key, field| field.namespace == namespace }
    end

  end

end
