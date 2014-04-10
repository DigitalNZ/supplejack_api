class Schema
  include SupplejackApi::SchemaDefinition

  # Fields
  [
    :record_id,  
    :status, 
    :internal_identifier, 
    :created_at, 
    :updated_at,
  ].each do |field|
    string field, store: false
  end
  
  string :name,         search_boost: 10,     search_as: [:fulltext]
  string :address,      search_boost: 2,      search_as: [:fulltext]
  string :email,        multi_value: true
  string :children,      multi_value: true
  boolean :nz_citizen,                        search_as: [:filter]
  datetime :birthdate
  integer :age

  # Roles
  role :developer do
  	default true
  end
  role :admin

  # Groups
  group :default do
    fields [
      :name,
      :address
    ]
  end
  group :all do
    fields [
      :name,
      :address,
      :nz_citizen,
      :birthdate,
      :age,
    ]
  end

end
