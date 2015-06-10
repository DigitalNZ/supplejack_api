# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

class ConceptSchema
  include SupplejackApi::SchemaDefinition

  # Namespaces
  namespace :dcterms,     url: 'http://purl.org/dc/terms/'
  namespace :edm,         url: 'http://www.europeana.eu/schemas/edm/'
  namespace :foaf,        url: 'http://xmlns.com/foaf/0.1/'
  namespace :owl,         url: 'http://www.w3.org/2002/07/owl#'
  namespace :rdaGr2,      url: 'http://rdvocab.info/ElementsGr2/'
  namespace :rdf,         url: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  namespace :rdfs,        url: 'http://www.w3.org/2000/01/rdf-schema#'
  namespace :skos,        url: 'http://www.w3.org/2004/02/skos/core#'
  namespace :xsd,         url: 'http://www.w3.org/2001/XMLSchema#'

  # Fields (SourceAuthority fields)
  string      :name
  string      :prefLabel
  string      :altLabel,                  multi_value: true
  datetime    :dateOfBirth
  datetime    :dateOfDeath
  string      :biographicalInformation
  string      :sameAs,                    multi_value: true
  string      :givenName
  string      :familyName
  string      :birthYear
  integer     :deathYear
  
  model_field :name, field_options: { type: String }, namespace: :foaf
  model_field :prefLabel, field_options: { type: String }, namespace: :skos
  model_field :altLabel, field_options: { type: Array }, namespace: :skos
  model_field :dateOfBirth, field_options: { type: Date }, namespace: :rdaGr2
  model_field :dateOfDeath, field_options: { type: Date }, namespace: :rdaGr2
  model_field :biographicalInformation, field_options: { type: String }, namespace: :rdaGr2
  model_field :sameAs, field_options: { type: Array }, namespace: :owl
end
