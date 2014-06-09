# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

class ConceptSchema < SupplejackApi::SupplejackSchema

  #namespaces
  namespace :label, url: 'http://www.w3.org/2004/02/skos/core#prefLabel'
  namespace :foaf, url: 'http://xmlns.com/foaf/0.1/'
  namespace :rdaGr2, url: 'http://rdvocab.info/ElementsGr2/'
  namespace :edm, url: 'http://www.europeana.eu/schemas/edm/'
  namespace :sameAs, url: 'http://www.w3.org/2002/07/owl#sameA'

  # namespace :description, description: 'rdaGr2:biographicalInformation'


  # Fields
<<<<<<< HEAD
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
=======
  string    :@id
  string    :@type
  string    :name,          search_boost: 10,   search_as: [:filter, :fulltext], namespace: :foaf
  string    :label,         search_boost: 5,    search_as: [:filter, :fulltext], namespace: :label
  string    :description,   search_boost: 2,    search_as: [:filter, :fulltext], namespace: :rdaGr2, namespace_field: :biographicalInformation
  datetime  :dateOfBirth,   namespace: :rdaGr2
  datetime  :dateOfDeath,   namespace: :rdaGr2
  string    :placeOfBirth,  namespace: :rdaGr2
  string    :placeOfDeath,  namespace: :rdaGr2
  string    :gender,        namespace: :rdaGr2
  string    :isRelatedTo,   multi_value: true, namespace: :edm
  string    :hasMet,        multi_value: true, namespace: :edm
  string    :sameAs,        multi_value: true, namespace: :sameAs
>>>>>>> Update concept serializer to use schema fields

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

  # Groups
  group :default do
    fields [
      :name,
      :description,
      :dateOfBirth,
      :dateOfDeath,
      :gender,
    ]
  end

  group :all_fields do
    includes [:internal_fields]
    includes [:default]
    fields [
      :label,
      :placeOfBirth,
      :placeOfDeath,
      :isRelatedTo,
      :hasMet,
      :sameAs,
    ]
  end

end
