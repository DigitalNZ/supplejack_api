# frozen_string_literal: true



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

          has_many :source_authorities, class_name: 'SupplejackApi::SourceAuthority', dependent: :destroy

          # Both of these fields are required in SJ API Core
          # No need to configure in *Schema
          field           :concept_type,         type: String
          auto_increment  :concept_id

          index({ concept_id: 1 }, unique: true)

          ConceptSchema.model_fields.each do |name, option|
            next if option.store == false
            field name.to_sym, option.field_options if !!option.field_options

            # TODO: Set the Mongo index
            # TODO: Set the validation
          end

          def records
            # Limit the number of records by 50
            SupplejackApi.config.record_class.where(concept_ids: id).limit(50).to_a
          end
        end

        def edm_type
          concept_type.gsub(/edm:/, '').downcase.pluralize
        end

        def site_id
          [ENV['CONCEPT_HTTP_HOST'], 'concepts', concept_id].join('/')
        end

        def context
          [ENV['HTTP_HOST'], 'schema'].join('/')
        end
      end
    end
  end
end
