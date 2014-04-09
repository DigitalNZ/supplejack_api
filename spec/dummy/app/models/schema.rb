class Schema
  include SupplejackApi::SchemaDefinition

  # Fields
  string :title, search_boost: 10, search_as: [:fulltext]

  # Roles
  role :developer do
  	default true
  end

  group :default do
    fields [
      :title
    ]
  end
end
