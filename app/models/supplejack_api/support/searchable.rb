# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Support
    module Searchable
    	extend ActiveSupport::Concern

    	included do
        include Sunspot::Mongoid
  
        searchable if: :should_index? do
          string :internal_identifier
          
          string :source_id do
            primary_fragment.source_id
          end
  
          self.build_sunspot_schema(self)
        end
      end

      SUNSPOT_TYPE_NAMES = {
        string: :string, 
        integer: :integer, 
        datetime: :time, 
        boolean: :boolean
      }

      module ClassMethods
      	def schema_class
		  		"#{self.to_s.demodulize}Schema".constantize
		  	end

        def build_sunspot_schema(builder)
          schema_class.fields.each do |name,field|
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
      
        def valid_facets
          facets = []

          schema_class.fields.each do |name,field|
            search_as = field.search_as || []
            facets << name.to_sym if search_as.include? :filter  
          end

          facets
        end
        
        def valid_groups
          schema_class.groups.keys
        end
      end

    end
  end
end
