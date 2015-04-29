# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Support
    module Storable
      extend ActiveSupport::Concern

    	included do
        include Mongoid::Document
    		include Mongoid::Timestamps
        include Mongoid::Attributes::Dynamic

        # Both of these fields are required in SJ API Core
        # No need to configure in *Schema
        field :internal_identifier,         type: String
        field :status,                      type: String
        field :record_type,                 type: Integer,      default: 0
        
        index status: 1
        index internal_identifier: 1
        index record_type: 1
        index({ record_id: 1 }, { unique: true })

        if %w(development staging).include?(Rails.env)
          auto_increment :record_id,        session: 'strong',  seed: 100000000
        else
          auto_increment :record_id,        session: 'strong'
        end

        def self.build_model_fields
          if RecordSchema.model_fields.present?
            RecordSchema.model_fields.each do |name, index|
              # Set the field
              field name.to_sym, index.field_options if !!index.field_options

              # Set the index
              index_fields = !!index.index_fields ? index.index_fields : {}
              index_options = !!index.index_options ? index.index_options : {}
              index index_fields, index_options unless index_fields.empty?

              # Set the validation
              validates name.to_sym, index.validation if !!index.validation
            end
          end
        end
      end
    end
  end
end
