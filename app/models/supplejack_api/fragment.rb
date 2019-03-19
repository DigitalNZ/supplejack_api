# frozen_string_literal: true

module SupplejackApi
  class Fragment
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Attributes::Dynamic

    default_scope -> { asc(:priority) }

    field :source_id, type: String
    field :priority,  type: Integer, default: 1
    field :job_id,  type: String

    MONGOID_TYPE_NAMES = {
      string: String,
      integer: Integer,
      datetime: DateTime,
      boolean: Boolean
    }.freeze

    def self.schema_class
      raise NotImplementedError, 'All subclasses of SupplejackApi::Fragment must define a #schema_class method.'
    end

    def self.build_mongoid_schema
      # Build fields
      schema_class.fields.each do |name, field|
        next if field.store == false
        type = field.multi_value.presence ? Array : MONGOID_TYPE_NAMES[field.type]
        self.field name, type: type
      end

      return if schema_class.mongo_indexes.blank?
      # Build indexes
      schema_class.mongo_indexes.each_value do |index|
        index_options = !!index.index_options ? index.index_options : {}
        self.index index.fields.first, index_options
      end
    end

    def primary?
      priority.zero?
    end
  end
end
