# frozen_string_literal: true

module SupplejackApi
  module ApiConcept
    class ConceptFragment < SupplejackApi::Fragment
      embedded_in :concept

      delegate :concept_id, to: :concept

      def self.schema_class
        ConceptSchema
      end

      build_mongoid_schema

      def self.mutable_fields
        @@mutable_fields ||= begin
                               immutable_fields = %w[_id _type source_id created_at updated_at]
                               mutable_fields = fields.keys - immutable_fields
                               Hash[mutable_fields.map { |name| [name, fields[name].type] }]
                             end.freeze
      end
    end
  end
end
