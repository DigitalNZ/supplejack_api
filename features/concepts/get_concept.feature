

@search
Feature: Get Concept

  Background:
    Given a user with a API Key
    And I have a concept

  Scenario: Show concept without inline context
    When I get a concept
    Then the JSON should be a hash
    And the JSON at "@context" should be "http://test.host/schema"
    And the JSON at "name" should be "Colin McCahon"

  Scenario: Show concept with inline context
    When I get a concept with inline context
    Then the JSON should be a hash
    And the JSON at "@context" should be:
      """
      {
        "skos": "http://www.w3.org/2004/02/skos/core#",
        "source_authority": {
          "@id": "foaf:source_authority"
        },
        "rdaGr2": "http://rdvocab.info/ElementsGr2/",
        "foaf": "http://xmlns.com/foaf/0.1/",
        "owl": "http://www.w3.org/2002/07/owl#",
        "dc": "http://purl.org/dc/elements/1.1/",
        "edm": "http://www.europeana.eu/schemas/edm/",
        "dcterms": "http://purl.org/dc/terms/",
        "concept_id": {
            "@id": "dcterms:identifier"
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
        "name": {
            "@id": "foaf:name"
        },
        "prefLabel": {
            "@id": "skos:prefLabel"
        },
        "sameAs": {
            "@id": "owl:sameAs"
        },
        "title": {
            "@id": "dc:title"
        },
        "date": {
            "@id": "dc:date"
        },
        "description": {
            "@id": "dc:description"
        },
        "agents": {
            "@id": "edm:agents"
        }
    }
    """

    Scenario: Filter concepts by source_authority
      When I get a concept
      And I filter a concept by source_authortiy
      Then the JSON should be a hash
      And the JSON at "concept_search/results/0/name" should be "Colin McCahon"
