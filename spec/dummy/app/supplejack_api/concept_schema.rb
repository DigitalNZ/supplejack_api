# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

class ConceptSchema < SupplejackApi::SupplejackSchema

  # Fields
  string    :type,                              search_as: [:filter]
  string    :name,          search_boost: 10,   search_as: [:filter, :fulltext]
  string    :label,         search_boost: 5,    search_as: [:filter, :fulltext]
  string    :description,   search_boost: 2,    search_as: [:filter, :fulltext]
  datetime  :dateOfBirth,                       search_as: [:filter]
  datetime  :dateOfDeath,                       search_as: [:filter]
  string    :placeOfBirth
  string    :placeOfDeath
  string    :gender,                            search_as: [:filter]
  string    :isRelatedTo,   multi_value: true
  string    :hasMet,        multi_value: true
  string    :sameAs,        multi_value: true

  # Groups
  group :default do
    fields [
      :type,
      :name,
      :label
    ]
  end

  group :all do
    includes [:default]
    fields [
      :description,
      :dateOfBirth,
      :dateOfDeath,
      :placeOfBirth,
      :placeOfDeath,
      :gender,
      :isRelatedTo,
      :hasMet,
      :sameAs,
    ]
  end

  build_object_id

end
