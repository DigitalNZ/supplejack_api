# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Concept
    include Support::Concept::Storable
    include ActiveModel::SerializerSupport

    has_many :source_authorities, class_name: 'SupplejackApi::SourceAuthority'

    def self.custom_find(id, scope=nil, options={})
      options ||= {}
      class_scope = self.unscoped
      column = "#{self.name.demodulize.downcase}_id"

      if id.to_s.match(/^\d+$/)
        data = class_scope.where(column => id).first
      elsif id.to_s.match(/^[0-9a-f]{24}$/i)
        data = class_scope.find(id)
      end
  
      raise Mongoid::Errors::DocumentNotFound.new(self, [id], [id]) unless data
        
      data
    end

    def self.build_context(fields)
      fields.sort!
      context = {}
      namespaces = []

      fields.each do |field|
        namespaces << ConceptSchema.model_fields[field].try(:namespace)
      end

      namespaces.compact.uniq.each do | namespace |
        context[namespace] = ConceptSchema.namespaces[namespace].url
        namespaced_fields = ConceptSchema.fields.select { |key, field| field.namespace == namespace }
        namespaced_fields.each do |name, field|
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
  end
end
