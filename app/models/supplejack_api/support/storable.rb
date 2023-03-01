# frozen_string_literal: true

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

        index({ status: 1 }, background: true)
        index({ internal_identifier: 1 }, unique: true, background: true)
        index({ record_type: 1 }, background: true)
        index({ record_id: 1 }, unique: true, background: true)

        def self.build_model_fields
          return if RecordSchema.model_fields.blank?

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
