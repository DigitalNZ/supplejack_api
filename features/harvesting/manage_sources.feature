

Feature: Manage Sources

  Background:
    Given a partners exists named "Down to the wire"

  Scenario: Create new source
    When I create a source with the JSON:
      """
        {
          "source": {
            "name": "Sample source"
            ,"source_id": "1234"
          }
        }
      """
    Then there should be a source called "Sample source"
    And there should be a source_id of "1234"

  Scenario: Create an existing source
    Given I create a source with the JSON:
      """
        {
          "source": {
            "_id": "5227ff3f5ea13a50ce000008"
            ,"name": "Sample source"
            ,"source_id": "1234"
          }
        }
      """
    And there should be a source called "Sample source"
    When I create a source with the JSON:
      """
        {
          "source": {
            "_id": "5227ff3f5ea13a50ce000008"
            ,"name": "YouTube"
            ,"source_id": "1234"
          }
        }
      """
    Then the source with id "5227ff3f5ea13a50ce000008" should be called "YouTube"


  Scenario: Get a source
    Given I have the following sources:
      | name     | source_id |
      | Source 1 | 1234      |
      | Source 2 | 4321      |

    When I get the first source
    Then the JSON should have "name"
    And the JSON should have "source_id"
    And the JSON at "name" should be "Source 1"

  Scenario: List all sources
    Given I have the following sources:
      | name     | source_id |
      | Source 1 | 1234      |
      | Source 2 | 4321      |

    When I list all sources
    Then the JSON at "sources" should have 2 entries
    And the JSON at "sources/0/name" should be "Source 1"
    And the JSON at "sources/1/name" should be "Source 2"

  Scenario: Update a source
    Given a source exists named "Sample source"
    When I update the source with:
    """
      {
        "source" : {
          "name": "New source name"
          ,"source_id": "9876"
        }
      }
    """
    Then there should be a source called "New source name"
    And there should be souce id with "9876"