# frozen_string_literal: true



module SupplejackApi
  module SupplejackSchema
    extend ActiveSupport::Concern
    include SupplejackApi::SchemaDefinition

    CORE_FIELDS = %i[
      internal_identifier
      status
      record_type
      created_at
      updated_at
    ].freeze

    included do
      CORE_FIELDS.each do |field|
        string field, store: false
      end

      group :internal_fields do
        fields CORE_FIELDS
      end

      # Index core fields in mongo
      # mongo_index :status,              fields: [{status: 1}]
      # mongo_index :internal_identifier, fields: [{internal_identifier: 1}]
      # mongo_index :updated_at,          fields: [{updated_at: 1}]
    end
  end
end
