# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

class RecordSchema
  include SupplejackApi::SupplejackSchema

  # Namespaces
  namespace :dc,        url: 'http://purl.org/dc/elements/1.1/'
  namespace :sj,        url: ''

  # Fields
  string    :record_id,                   store: false,                                           namespace: :sj
  string    :concept_ids,                                                                         namespace: :sj
  string    :title,                       search_boost: 10,     search_as: [:filter, :fulltext],  namespace: :dc
  string    :description,                 search_boost: 2,      search_as: [:filter, :fulltext],  namespace: :dc
        
  string    :display_content_partner,                           search_as: [:filter, :fulltext],  namespace: :sj
  string    :display_collection,                                search_as: [:filter, :fulltext],  namespace: :sj
  string    :source_url,                                                                          namespace: :sj
  string    :thumbnail_url
  string    :subject,                     multi_value: true,                                      namespace: :dc
  string    :display_date,                                                                        namespace: :sj
  string    :creator,                     multi_value: true,                                      namespace: :dc
  string    :category,                    multi_value: true,    search_as: [:filter],             namespace: :sj

  # Groups
  group :default do
    fields [
      :title,
      :description
    ]
  end

  group :all do
    includes [:default]
    fields [
      :record_id,
      :concept_ids,
      :subject,
      :display_content_partner,
      :display_collection,
      :source_url,
      :thumbnail_url,
      :display_date,
      :creator,
      :category
    ]
  end

  group :core do
    fields [:record_id]
  end

   # Roles
  role :developer do
    default true
  end
  role :admin

  mongo_index :source_url,         fields: [{source_url: 1}]

end
