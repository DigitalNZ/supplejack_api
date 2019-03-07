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

    # def clear_attributes
    #   mutable_fields = self.class.mutable_fields.dup
    #   mutable_fields.delete('priority') if primary?
    #   raw_attributes.each_key do |name|
    #     self[name] = nil if mutable_fields.key?(name)
    #   end
    # end

    # def update_from_harvest(attributes = {})
    #   attributes = attributes.try(:symbolize_keys) || {}
    #
    #   self.source_id = Array(attributes[:source_id]).first if attributes[:source_id].present?
    #
    #   attributes.each do |field, value|
    #     if self.class.mutable_fields[field.to_s] == Array
    #       self[field] ||= []
    #       values = *value
    #       existing_values = *self[field]
    #       values = existing_values += values
    #       send("#{field}=", values.uniq)
    #     elsif self.class.mutable_fields[field.to_s]
    #       value = value.first if value.is_a?(Array)
    #       send("#{field}=", value)
    #     end
    #   end
    #
    #   self.updated_at = Time.now
    # end
  end
end
