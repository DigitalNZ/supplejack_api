# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
    Then the JSON at "search/results/0/name/0" should be "<name>"
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
    And the JSON at "search/results/0/name/0" should be "Rita Angus"
    And the JSON at "search/results/1/name/0" should be "Robert Muldoon"

  Scenario: Search for a concept using the NOT operator
    When I search concept for "david NOT hill"
    Then the JSON at "search/result_count" should be 1
    And the JSON at "search/results/0/name/0" should be "David Lange"

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

  Scenario: Search for a concept from a valid field
    When I search concept for "politician" within "description" field
    Then the JSON at "search/result_count" should be 1
    And the JSON at "search/results/0/name/0" should be "David Lange"

  Scenario: Search for a concept from an invalid field
    When I search concept for "politician" within "name" field
    Then the JSON at "search/result_count" should be 0

  Scenario: Sort search results in ascending order
    When I search concept with sort by "dateOfBirth" in "asc" order
    Then the JSON at "search/results" should be an array
    And the JSON at "search/result_count" should be 5
    And the JSON at "search/results/0/name/0" should be "Colin McCahon"
    And the JSON at "search/results/1/name/0" should be "Rita Angus"
    And the JSON at "search/results/2/name/0" should be "David Hill"
    And the JSON at "search/results/3/name/0" should be "David Lange"
    And the JSON at "search/results/4/name/0" should be "Robert Muldoon"

  Scenario: Sort search results in descending order
    When I search concept with sort by "dateOfBirth" in "desc" order
    Then the JSON at "search/results" should be an array
    And the JSON at "search/result_count" should be 5
    And the JSON at "search/results/0/name/0" should be "Robert Muldoon"
    And the JSON at "search/results/1/name/0" should be "David Lange"
    And the JSON at "search/results/2/name/0" should be "David Hill"
    And the JSON at "search/results/3/name/0" should be "Rita Angus"
    And the JSON at "search/results/4/name/0" should be "Colin McCahon"

  Scenario: Display specific field
    When I search concept for "politician" with "name,description" fields
    Then the JSON at "search/results" should be an array
    And the JSON at "search/result_count" should be 1
    And the JSON at "search/results/0/name/0" should be "David Lange"
    And the JSON at "search/results/0/description" should be "David Lange is a politician"
    And the JSON at "search/results/0" should have 3 entries

