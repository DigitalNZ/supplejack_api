# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	module ApiRecord
	  class RecordFragment < SupplejackApi::Fragment

	    delegate :record_id, to: :record
	  
       def self.build_mongoid_schema
        RecordSchema.fields.each do |name, field|
          next if field.store == false
          type = field.multi_value.presence ? Array : MONGOID_TYPE_NAMES[field.type]
          self.field name, type: type
        end
      end

      build_mongoid_schema

	  end
	end
end
