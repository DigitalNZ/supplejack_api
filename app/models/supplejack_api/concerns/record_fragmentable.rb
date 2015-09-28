module SupplejackApi::Concerns::RecordFragmentable
  extend ActiveSupport::Concern

  included do
    embedded_in :record

    delegate :record_id, to: :record

    def self.schema_class
      RecordSchema
    end

    build_mongoid_schema

    def self.mutable_fields
      @@mutable_fields ||= begin
        immutable_fields = ['_id', '_type', 'source_id', 'created_at', 'updated_at']
        mutable_fields = self.fields.keys - immutable_fields
        Hash[mutable_fields.map {|name| [name, self.fields[name].type] }]
      end.freeze
    end
  end

end
