# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

class ConceptSchema
  include SupplejackApi::SupplejackSchema

  #namespaces
  namespace :skos,   url: 'http://www.w3.org/2004/02/skos/core'
  namespace :foaf,   url: 'http://xmlns.com/foaf/0.1/'
  namespace :rdaGr2, url: 'http://rdvocab.info/ElementsGr2/'
  namespace :edm,    url: 'http://www.europeana.eu/schemas/edm/'
  namespace :owl,    url: 'http://www.w3.org/2002/07/owl'

  # Fields
  string    :concept_id,    store: false
  string    :type
  string    :match_status,  search_as: [:filter]
  # TODO Remove name
  string    :name,          multi_value: true,    search_boost: 10,     search_as: [:filter, :fulltext], namespace: :foaf
  string    :givenName,     search_boost: 10,     search_as: [:filter, :fulltext], namespace: :foaf
  string    :familyName,    search_boost: 10,     search_as: [:filter, :fulltext], namespace: :foaf
  string    :label,         search_boost: 5,      search_as: [:filter, :fulltext], namespace: :skos, namespace_field: :prefLabel
  string    :description,   search_boost: 2,      search_as: [:filter, :fulltext], namespace: :rdaGr2, namespace_field: :biographicalInformation
  datetime  :dateOfBirth,   search_as: [:filter], namespace: :rdaGr2
  datetime  :dateOfDeath,   search_as: [:filter], namespace: :rdaGr2
  string    :placeOfBirth,  namespace: :rdaGr2  
  string    :placeOfDeath,  namespace: :rdaGr2  
  string    :role,          namespace: :rdaGr2,   namespace_field: :professionOrOccupation
  string    :gender,        search_as: [:filter], namespace: :rdaGr2
  string    :isRelatedTo,   multi_value: true,    namespace: :edm
  string    :hasMet,        multi_value: true,    namespace: :edm
  string    :sameAs,        multi_value: true,    namespace: :owl

  # Groups
  group :default do
    fields [
      :type,
      :label,
      :name,
      :role
    ]
  end

  group :all do
    includes [:default]
    fields [
      :match_status,
      :name,
      :givenName,
      :familyName,
      :description,
      :dateOfBirth,
      :dateOfDeath,
      :placeOfBirth,
      :placeOfDeath,
      :gender,
      :isRelatedTo,
      :hasMet,
      :sameAs
    ]
  end

  group :core do
    fields [:concept_id]
  end

  # Roles
  role :developer do
    default true
  end
  role :admin

end
