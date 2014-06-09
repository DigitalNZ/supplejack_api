# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptSerializer < ActiveModel::Serializer

<<<<<<< HEAD
     def serializable_hash
      hash = attributes
      include_context_fields!(hash)

      groups = (options[:groups] & ConceptSchema.groups.keys) || []

      fields = Set.new
      groups.each do |group|
        fields.merge(ConceptSchema.groups[group].try(:fields))
      end

      fields.each do |field|
        hash[field] = field_value(field, options)
      end

      include_individual_fields!(hash)
      hash
    end

    def include_context_fields!(hash)
      context = build_context
      hash['@context'] = context
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

    def field_value(field, options={})
      value = nil

      if ConceptSchema.fields[field].try(:search_value) && ConceptSchema.fields[field].try(:store) == false
        value = ConceptSchema.fields[field].search_value.call(object)
      else
        value = object.public_send(field)
      end

      value
    end

    def build_context
      context = {}

      ConceptSchema.namespaces.each do | key, namespace |
        context[key] = "#{namespace.url}"
        namespaced_fields(key).each do |name, field|
          context[name] = "#{field.namespace}:#{field.namespace_field}" unless name == field.namespace
        end
      end

      context
    end

    def namespaced_fields(namespace)
      ConceptSchema.fields.select { |key, field| field.namespace == namespace }
    end

  end

end
