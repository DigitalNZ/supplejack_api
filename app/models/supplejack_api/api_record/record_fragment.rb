# frozen_string_literal: true

module SupplejackApi
  module ApiRecord
    class RecordFragment < SupplejackApi::Fragment
      embedded_in :record

      delegate :record_id, to: :record

      def self.schema_class
        RecordSchema
      end

      build_mongoid_schema

      def self.mutable_fields
        @mutable_fields ||= begin
          immutable_fields = %w[_id _type source_id created_at updated_at]
          mutable_fields = fields.keys - immutable_fields
          mutable_fields.index_with { |name| fields[name].type }
        end.freeze
      end
    end
  end
end
