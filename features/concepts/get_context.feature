

Feature: Get Context

  Background:
    Given a user with a API Key

  Scenario: Show context
    When I visit "/schema"
    Then the JSON should be a hash
    And the JSON should be:
      """
      {
        "foaf": "http://xmlns.com/foaf/0.1/",
        "skos": "http://www.w3.org/2004/02/skos/core#",
        "source_authority": {
          "@id": "foaf:source_authority"
        },
        "rdaGr2": "http://rdvocab.info/ElementsGr2/",
        "owl": "http://www.w3.org/2002/07/owl#",
        "dc": "http://purl.org/dc/elements/1.1/",
        "edm": "http://www.europeana.eu/schemas/edm/",
        "dcterms": "http://purl.org/dc/terms/",
        "concept_id": {
            "@id": "dcterms:identifier"
        },
        "name": {
            "@id": "foaf:name"
        },
        "prefLabel": {
            "@id": "skos:prefLabel"
        },
        "altLabel": {
            "@id": "skos:altLabel"
        },
        "dateOfBirth": {
            "@id": "rdaGr2:dateOfBirth"
        },
        "dateOfDeath": {
            "@id": "rdaGr2:dateOfDeath"
        },
        "biographicalInformation": {
            "@id": "rdaGr2:biographicalInformation"
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
