module SupplejackApi
	class SupplejackSchema
		include SupplejackApi::SchemaDefinition

	  # Make core fields available in Schema
	  [
	    :record_id,  
	    :status, 
	    :internal_identifier, 
	    :created_at, 
	    :updated_at
	  ].each do |field|
	    string field, store: false
	  end

	  group :supplejack_fields do
	    fields [
	      :record_id,  
		    :status, 
		    :internal_identifier, 
		    :created_at, 
		    :updated_at
	    ]
	  end
	end
end