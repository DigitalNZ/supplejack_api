

Feature: Manage individual items

  Background:
    Given a user with a API Key
    And these records:
      | record_id | name         | address            | email                       | age | children   | nz_citizen |
      | 78        | John Doe     | Wellington         | ["john@example.com"]        | 30  | ["Sally"]  | true       |
      | 79        | Sally Smith  | Auckland           | ["sally@example.com"]       | 22  | ["James"]  | true       |
      | 12        | Steve Jobs   | Parker St. Dunedin | ["stevejobs@example.com"]   | 62  | ["Samuel"] | false      |
      | 55        | Peter Parker | Christchruch       | ["peterparker@example.com"] | 42  | ["Lily"]   | false      |
    And I have a set with name "Dogs and cats"
    And the set has the following items:
      | record_id | position  |
      | 12        | 1         |

  Scenario: Add an item to a set
    When I post a request to add a set item with the JSON:
    """
    {
      "record": {
        "record_id": 78
      }
    }
    """
    Then there should be 2 items in the set
    And the item with record_id of 78 should have a "position" of 2

  Scenario: Delete an item from a set
    When I issue a delete request to remove set item with record_id 12
    Then there should be 0 items in the set