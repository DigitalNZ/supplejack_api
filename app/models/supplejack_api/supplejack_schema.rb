# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	class SupplejackSchema
		include SupplejackApi::SchemaDefinition

		CORE_FIELDS = [
	    :record_id,  
	    :internal_identifier, 
	    :status, 
	    :landing_url,
	    :created_at, 
	    :updated_at
	  ]

	  # Make core fields available in Schema
	  CORE_FIELDS.each do |field|
	    string field, store: false
	  end

	  group :internal_fields do
	    fields CORE_FIELDS
	  end
	end
end