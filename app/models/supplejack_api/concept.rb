# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Concept
    include Support::Concept::Storable
    include Support::Concept::Searchable
    include ActiveModel::SerializerSupport

    def self.build_context(fields)
      context = {}
      namespaces = []

      fields.each do |field|
        namespaces << ConceptSchema.model_fields[field].try(:namespace)
      end

      namespaces.compact.uniq.each do | namespace |
        context[namespace] = ConceptSchema.namespaces[namespace].url
        namespaced_fields = ConceptSchema.fields.select { |key, field| field.namespace == namespace }
        namespaced_fields.each do |name, field|
          if fields.include?(name) && name != field.namespace
            context[name] = "#{field.namespace}:#{field.namespace_field}" 
          end
        end
      end

      # Manually build context for concept_id
      context[:dcterms] = ConceptSchema.namespaces[:dcterms].url
      context[:concept_id] = {}
      context[:concept_id]["@id"] = "dcterms:identifier"

      fields.each do |field|        
        context[field] = {}
        namespace = ConceptSchema.model_fields[field].try(:namespace)
        context[field]['@id'] = "#{namespace}:#{field.to_s}"
      end
      context
    end
  end
end
