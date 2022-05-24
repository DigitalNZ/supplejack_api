class RecordSchema
  include SupplejackApi::SupplejackSchema

  # Namespaces
  namespace :dc, url: 'http://purl.org/dc/elements/1.1/'

  # Fields
  string   :record_id, store: false
  string   :name,                                     search_as: [:filter, :fulltext],       namespace: :dc, search_boost: 10
  string   :title,                                    search_as: [:filter, :fulltext, :mlt], namespace: :dc, search_boost: 10
  string   :address,                                  search_as: [:filter, :fulltext],                       search_boost: 2
  string   :email,                 multi_value: true, search_as: [:filter]
  string   :children,              multi_value: true
  string   :contact,               multi_value: true
  integer  :age,                                      search_as: [:filter]
  datetime :birth_date,                               search_as: [:filter]
  datetime :date,                  multi_value: true, search_as: [:filter]
  datetime :sort_date,                                search_as: [:filter]
  boolean  :nz_citizen,                               search_as: [:filter]
  string   :display_collection,                       search_as: [:filter, :fulltext],       namespace: :sj
  string   :tag,                   multi_value: true, search_as: [:filter]
  string   :description,                              search_as: [:filter, :fulltext],       namespace: :dc, search_boost: 2
  string   :rights,                                   search_as: [:filter],                  namespace: :dc
  string   :content_partner,       multi_value: true,                                        namespace: :dc
  string   :creator,               multi_value: true, search_as: [:filter, :fulltext],       namespace: :dc
  string   :contributing_partner,  multi_value: true, search_as: [:fulltext],                namespace: :dc
  string   :subject,               multi_value: true, search_as: [:filter, :fulltext, :mlt], namespace: :dc
  # facets
  string    :category,             multi_value: true, search_as: [:filter]
  string    :copyright,            multi_value: true, search_as: [:filter]


  string  :thumbnail_url
  string  :large_thumbnail_url
  string  :landing_url, namespace: :dc
  string :block_example do
    store false
    search_value do |record|
      'Value of the block'
    end
  end

  string :default_example, default_value: 'Default value'
  datetime :created_at, date_format: '%y/%d/%m'

  # Groups
  group :default do
    fields [
      :name,
      :address,
      :email
    ]
  end

  group :verbose do
    includes [:default]
    fields [
      :email,
      :children,
      :nz_citizen,
      :birth_date,
      :age,
      :landing_url,
      :subject
    ]
  end

  group :core do
    fields [:record_id]
  end

  group :sets do
    fields [
      :name,
      :address
    ]
  end

  group :valid_set_fields do
    includes [:sets]
    fields [
      :tag
    ]
  end

   # Roles
  role :anonymous, anonymous: true
  role :developer, default: true
  role :admin, admin: true
  role :harvester, harvester: true

  model_field :index_updated, field_options: { type: Mongoid::Boolean }
  model_field :index_updated_at, field_options: { type: DateTime }
end
