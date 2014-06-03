# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	class SupplejackSchema
		include SupplejackApi::SchemaDefinition

		CORE_FIELDS = [
	    :internal_identifier, 
	    :status, 
	    :landing_url,
	    :created_at, 
	    :updated_at
	  ]

	  def self.build_object_id
	  	object_id = "#{self.name.to_s.gsub(/Schema/, '').downcase}_id".to_sym
	  	
			# Make core fields available in Schema
	  	CORE_FIELDS.push object_id
	  	CORE_FIELDS.each do |field|
		    string field, store: false
		  end

	  	group :core do
		    fields [object_id]
		  end
	  end

	  group :internal_fields do
	    fields CORE_FIELDS
	  end
	end
end
