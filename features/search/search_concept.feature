@search
Feature: Search Concept

  Background:
    Given a user with a API Key
    And these concepts:
      | label          | name           | gender | dateOfBirth | dateOfDeath | description                 |
      | Colin McCahon  | Colin McCahon  | male   | 01/01/1921  | 01/01/1941  | Colin McCahon is an artist  |
      | Rita Angus     | Rita Angus     | female | 02/02/1922  | 01/01/1942  | Rita Angus is a female      |
      | David Hill     | David Hill     | male   | 03/03/1923  | 01/01/1943  | David Hill is a painter     |
      | David Lange    | David Lange    | male   | 04/04/1924  | 01/01/1944  | David Lange is a politician |
      | Robert Muldoon | Robert Muldoon | male   | 05/05/1925  | 01/01/1945  | Robert was a volunteer      |

  Scenario Outline: Find concepts by term and return JSON
    When I search concept for "<term>"
    Then the JSON at "search/results/0/name" should be "<name>"
    And the JSON at "search/results" should have <num results> entries
    
    Examples:
      | term    | name           | num results |
      | mccahon | Colin McCahon  | 1           |
      | rita    | Rita Angus     | 1           |
      | david   | David Hill     | 2           |
      | muldoon | Robert Muldoon | 1           |

  Scenario: Search all concepts
    When I visit index page for the concepts
    Then the JSON at "search/result_count" should be 5
    And the JSON at "search/results" should be an array
    And the JSON at "search/per_page" should be 20
    And the JSON at "search/page" should be 1
    And the JSON at "search/request_url" should be the requested url

  Scenario: Search for a concept
    When I search concept for "Muldoon"
    Then the JSON at "search/results" should be an array
    And the JSON at "search/facets" should be an hash
    And the JSON at "search/result_count" should be 1
    And the JSON at "search/per_page" should be 20
    And the JSON at "search/page" should be 1
    And the JSON at "search/request_url" should be the requested url

  Scenario: Search for a concept using the OR operator
    When I search concept for "Rita OR Robert"
    Then the JSON at "search/result_count" should be 2
    And the JSON at "search/results/0/name" should be "Rita Angus"
    And the JSON at "search/results/1/name" should be "Robert Muldoon"

  Scenario: Scenario: Search for a concept using the NOT operator
    When I search concept for "david NOT hill"
    Then the JSON at "search/result_count" should be 1
    And the JSON at "search/results/0/name" should be "David Lange"

  Scenario: Should not search concept for the term in other fields
    When I search concept for a field "hasMet_sm:\"Obama\""
    Then the JSON at "search/result_count" should be 0

  Scenario: Return facets in JSON format
    When I search concept for "David" with facet "name"
    Then the JSON at "search/facets" should be:
    """
      {
        "name": {
          "David Hill": 1,
          "David Lange": 1
        }
      }
    """
