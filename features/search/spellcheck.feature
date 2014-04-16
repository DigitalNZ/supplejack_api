@search
Feature: Spellcheck
  
  Background:
    Given a user with a API Key
    And these records:
      | name        | address    | email                 | age | children  | nz_citizen |
      | John Doe    | Wellington | ["john@example.com"]  | 30  | ["Sally"] | true       |
      | Sally Smith | Auckland   | ["sally@example.com"] | 22  | ["James"] | true       |

  Scenario: Search with suggest
    # When I search for "jahn" with suggest
    # Then the JSON at "search/suggestion" should be "john"

  Scenario: Search without suggest
    # When I search for "jahn"
    # Then the JSON should not have "search/suggestion"
