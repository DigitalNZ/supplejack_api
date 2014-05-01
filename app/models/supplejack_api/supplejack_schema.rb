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