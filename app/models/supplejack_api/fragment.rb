# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	class Fragment
		include Mongoid::Document
	  include Mongoid::Timestamps

	  default_scope asc(:priority)
	  
	  field :source_id, type: String
	  field :priority,  type: Integer, default: 1
	  field :job_id,  type: String

	  MONGOID_TYPE_NAMES = {
      string: String, 
      integer: Integer, 
      datetime: DateTime, 
      boolean: Boolean
    }

    def self.schema_class
      raise NotImplementedError.new("All subclasses of SupplejackApi::Fragment must define a #schema_class method.")
    end

    def self.build_mongoid_schema
      self.schema_class.fields.each do |name, field|
        next if field.store == false
        type = field.multi_value.presence ? Array : MONGOID_TYPE_NAMES[field.type]
        self.field name, type: type
      end
    end

    def primary?
      self.priority == 0
    end
  
    def clear_attributes
      mutable_fields = self.class.mutable_fields.dup
      mutable_fields.delete("priority") if self.primary?
      self.raw_attributes.each do |name, value|
        self[name] = nil if mutable_fields.has_key?(name)
      end
    end

    def update_from_harvest(attributes={})
      attributes = attributes.try(:symbolize_keys) || {}

      self.source_id = Array(attributes[:source_id]).first if attributes[:source_id].present?

      attributes.each do |field, value|
        if self.class.mutable_fields[field.to_s] == Array
          self[field] ||= []
          values = *value
          existing_values = *self[field]
          values = existing_values += values
          self.send("#{field}=", values.uniq)
        elsif self.class.mutable_fields[field.to_s]
          value = value.first if value.is_a?(Array)
          self.send("#{field}=", value)
        end
      end

      self.updated_at = Time.now
    end
	end
end
