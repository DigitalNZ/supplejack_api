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
  namespace :dc,          url: 'http://purl.org/dc/elements/1.1/'

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
  integer     :birthYear
  integer     :deathYear

  group :source_authorities
  group :reverse

  group :default do
    fields [
      :name,
      :title
    ]
  end

  group :verbose do
    fields [
      :name,
      :prefLabel,
      :altLabel,
      :dateOfBirth,
      :dateOfDeath,
      :biographicalInformation,
      :sameAs,
      :title
    ]
  end

  # Concept
  model_field :name, field_options: { type: String }, search_as: [:fulltext], search_boost: 6, namespace: :foaf
  model_field :prefLabel, field_options: { type: String }, namespace: :skos
  model_field :altLabel, field_options: { type: Array }, search_as: [:fulltext], search_boost: 2, namespace: :skos
  model_field :dateOfBirth, field_options: { type: Date }, namespace: :rdaGr2
  model_field :dateOfDeath, field_options: { type: Date }, namespace: :rdaGr2
  model_field :biographicalInformation, field_options: { type: String }, search_as: [:fulltext], search_boost: 1,  namespace: :rdaGr2
  model_field :sameAs, field_options: { type: Array }, namespace: :owl

  # Use store: false to display the fields in the /schema
  model_field :title, store: false, namespace: :dc
  model_field :date, store: false, namespace: :dc
  model_field :description, store: false, namespace: :dc
  model_field :agents, store: false, namespace: :edm
  model_field :source_authority do
    search_as [:filter]
    store false
    type :string
    multi_value true
    namespace :foaf
    search_value do |concept|
      concept.source_authorities.map(&:internal_identifier)
    end
  end
end
