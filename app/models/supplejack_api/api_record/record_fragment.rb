# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	module ApiRecord
	  class RecordFragment < SupplejackApi::Fragment

	    embedded_in :record

      delegate :record_id, to: :record

      def self.schema_class
        'RecordSchema'.constantize
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
end
