# frozen_string_literal: true

module SupplejackApi
  class Concept
    include Support::Concept::Storable
    include Support::Concept::Searchable

    index({ concept_id: 1 }, background: true)

    def self.build_context(fields)
      context = {}
      namespaces = []

      fields.each do |field|
        namespaces << ConceptSchema.model_fields[field].try(:namespace)
      end

      namespaces.compact.uniq.each do |namespace|
        context[namespace] = ConceptSchema.namespaces[namespace].url
        namespaced_fields = ConceptSchema.fields.select { |_key, field| field.namespace == namespace }
        namespaced_fields.each do |name, field|
          if fields.include?(name) && name != field.namespace
            context[name] = "#{field.namespace}:#{field.namespace_field}"
          end
        end
      end

      # Manually build context for concept_id
      context[:dcterms] = ConceptSchema.namespaces[:dcterms].url
      context[:concept_id] = {}
      context[:concept_id]['@id'] = 'dcterms:identifier'

      fields.each do |field|
        context[field] = {}
        namespace = ConceptSchema.model_fields[field].try(:namespace)
        context[field]['@id'] = "#{namespace}:#{field}"
      end
      context
    end
  end
end
