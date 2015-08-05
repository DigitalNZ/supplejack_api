# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Support
    module Concept
      module Searchable
        extend ActiveSupport::Concern

        SUNSPOT_TYPE_NAMES = {
          string: :string, 
          integer: :integer, 
          datetime: :time, 
          boolean: :boolean,
          latlon: :latlon
        }

        included do
          include Sunspot::Mongoid
    
          searchable do
            build_sunspot_schema(self)
          end # searchable
        end # included

        module ClassMethods
          def custom_find(id, scope=nil, options={})
            options ||= {}
            class_scope = self.unscoped

            if id.to_s.match(/^\d+$/)
              data = class_scope.where(concept_id: id).first
            elsif id.to_s.match(/^[0-9a-f]{24}$/i)
              data = class_scope.find(id)
            end
        
            raise Mongoid::Errors::DocumentNotFound.new(self, [id], [id]) unless data

            data
          end

          def build_sunspot_schema(builder)
            ConceptSchema.model_fields.each do |name, field|
              options = {}
              search_as = field.search_as || []
    
              value_block = nil
              if field.search_value.present?
                value_block = Proc.new do
                  field.search_value.call(self)
                end
              end
    
              options[:as] = field.solr_name if field.solr_name.present?
    
              if search_as.include? :filter
                filter_options = {}
                filter_options[:multiple] = true if field.multi_value.present?
                type = SUNSPOT_TYPE_NAMES[field.type]
    
                builder.public_send(type, field.name, options.merge(filter_options), &value_block)
              end
    
              if search_as.include? :fulltext
                options[:boost] = field.search_boost if field.search_boost.present?
                builder.text field.name, options, &value_block
              end
            end
          end
        end # module ClassMethods

      end # module Searchable
    end # module Concept
  end # module Support
end # module SupplejackApi
