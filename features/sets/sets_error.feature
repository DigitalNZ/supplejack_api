

Feature: Sets Errors

  Background:
    Given a user with a API Key
    And these records:
      | record_id | name         | address            | email                       | age | children   | nz_citizen |
      | 78        | John Doe     | Wellington         | "john@example.com"        | 30  | "Sally"  | true       |

  Scenario: Try to create a set without a name
    When I post a request to create a set with the JSON:
    """
    {
      "set": {
        "privacy": "hidden",
        "records": [{
          "record_id": 78
        }]
      }
    }
    """
    Then I should have 0 sets