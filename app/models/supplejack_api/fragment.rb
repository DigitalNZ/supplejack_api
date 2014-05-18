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
  
    delegate :record_id, to: :record
  
    embedded_in :record
    
    default_scope asc(:priority)
  
    field :source_id, type: String
  
    # The priority is a integer value that can range from negative to positive values
    # the sources will be merged from positive to negative, which means that for single
    # value fields sources with a lower numerical priority will take precedence.
    #
    # As a example the thumbnails enrichment source should have a negative (ex. -1) so that
    # the thumbnails data in the thumbnail enrichment source is chosen over the 
    # primary_source (priority 0).
    #
    field :priority,  type: Integer, default: 1

    # Job ID uniquely identifies all sources that were written by one harvest or enrichment job
    field :job_id,  type: String
  
    MONGOID_TYPE_NAMES = {
      string: String, 
      integer: Integer, 
      datetime: DateTime, 
      boolean: Boolean
    }
  
    def self.build_mongoid_schema
      Schema.fields.each do |name, field|
        next if field.store == false
        type = field.multi_value.presence ? Array : MONGOID_TYPE_NAMES[field.type]
        self.field name, type: type
      end
    end
    
    build_mongoid_schema
  
    def self.mutable_fields
      @@mutable_fields ||= begin
        immutable_fields = ['_id', '_type', 'source_id', 'created_at', 'updated_at']
        mutable_fields = self.fields.keys - immutable_fields
        Hash[mutable_fields.map {|name| [name, self.fields[name].type] }]
      end.freeze
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
