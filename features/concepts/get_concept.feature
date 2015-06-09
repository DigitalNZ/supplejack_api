# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

@search
Feature: Get Concept

	Background:
		Given a user with a API Key
		And a concept

	Scenario: Show concept without inline context
		When I get a concept
		Then the JSON should be a hash
    And the JSON at "@context" should be "http://digitalnz.org/schema"
		And the JSON at "name" should be "Colin McCahon"

  Scenario: Show concept with inline context
    When I get a concept with inline context
    Then the JSON should be a hash
    And the JSON at "name" should be "Colin McCahon"
    And the JSON at "@context" should be:
      """
      {
        "@id": {
          "@id": ":@id"
        },
        "@type": {
          "@id": ":@type"
        },
        "altLabel": {
          "@id": "skos:altLabel"
        },
        "biographicalInformation": {
          "@id": "rdaGr2:biographicalInformation"
        },
        "dateOfBirth": {
          "@id": "rdaGr2:dateOfBirth"
        },
        "dateOfDeath": {
          "@id": "rdaGr2:dateOfDeath"
        },
        "foaf": "http://xmlns.com/foaf/0.1/",
        "name": {
          "@id": "foaf:name"
        },
        "owl": "http://www.w3.org/2002/07/owl#",
        "prefLabel": {
          "@id": "skos:prefLabel"
        },
        "rdaGr2": "http://rdvocab.info/ElementsGr2/",
        "sameAs": {
          "@id": "owl:sameAs"
        },
        "skos": "http://www.w3.org/2004/02/skos/core#"
      }
      """
