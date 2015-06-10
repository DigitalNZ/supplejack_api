# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Support
    module Concept
      module Storable
        extend ActiveSupport::Concern

      	included do
          include Mongoid::Document
      		include Mongoid::Timestamps
          include Mongoid::Attributes::Dynamic

          store_in collection: 'concepts'

          attr_accessor :site_id, :context

          has_many :source_authorities, class_name: 'SupplejackApi::SourceAuthority'
          has_and_belongs_to_many :records, class_name: 'SupplejackApi::Record'

          # Both of these fields are required in SJ API Core
          # No need to configure in *Schema
          field           :@type,         type: String 
          auto_increment  :concept_id
          
          index({ concept_id: 1 }, { unique: true })

          ConceptSchema.model_fields.each do |name, option|
            next if option.store == false
            field name.to_sym, option.field_options if !!option.field_options

            # TODO: Set the Mongo index
            # TODO: Set the validation
          end
        end # included

      end # module
    end
  end
end
