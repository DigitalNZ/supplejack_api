# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
