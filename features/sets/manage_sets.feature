# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Feature: Manage sets

  Background:
    Given a user with a API Key
    And these records:
      | record_id | name         | address            | email                       | age | children   | nz_citizen |
      | 78        | John Doe     | Wellington         | "john@example.com"        | 30  | "Sally"  | true       |
      | 79        | Sally Smith  | Auckland           | "sally@example.com"       | 22  | "James"  | true       |
      | 12        | Steve Jobs   | Parker St. Dunedin | "stevejobs@example.com"   | 62  | "Samuel" | false      |
      | 55        | Peter Parker | Christchruch       | "peterparker@example.com" | 42  | "Lily"   | false      |
  
  Scenario: Create a set
    When I post a request to create a set with the JSON:
    """
    {
      "set": {
        "name": "Dogs and cats",
        "description": "Ugly dogs and cats",
        "privacy": "hidden",
        "records": [{
          "record_id": 55
        }]
      }
    }
    """
    Then I should have a set with the values:
      | field       | value               |
      | name        | Dogs and cats       |
      | description | Ugly dogs and cats  |
      | privacy     | hidden              |
      | count       | 1                   |

  Scenario: Update a set
    Given I have a set with name "Dogs and cats"
    When I do a put request to update the set with the JSON:
    """
    {
      "set": {
        "records": [{
          "record_id": 78,
          "position": 1
        },{
          "record_id": 79,
          "position": 2
        },{
          "record_id": 12,
          "position": 3
        }]
      }
    }
    """
    Then the set should have 3 set items with the values:
      | record_id | position  |
      | 78        | 1         |
      | 79        | 2         |
      | 12        | 3         |

  Scenario: Add tags
    Given I have a set with name "Dogs and cats"
    When I do a put request to update the set with the JSON:
    """
    {
      "set": {
        "tags": ["dogs", "cats"]
      }
    }
    """
    Then the set should have 2 tags the values:
      | tags |
      | dogs |
      | cats |

  Scenario: Update items order
    Given I have a set with name "Dogs and cats"
    When I do a put request to update the set with the JSON:
    """
    {
      "set": {
        "records": [{
          "record_id": 78,
          "position": 1
        },{
          "record_id": 79,
          "position": 2
        },{
          "record_id": 12,
          "position": 3
        }]
      }
    }
    """
    And I do a put request to update the set with the JSON:
    """
    {
      "set": {
        "records": [{
          "record_id": 78,
          "position": 3
        },{
          "record_id": 79,
          "position": 2
        },{
          "record_id": 12,
          "position": 1
        }]
      }
    }
    """
    Then the set should have 3 set items with the values:
      | record_id | position  |
      | 78        | 3         |
      | 79        | 2         |
      | 12        | 1         |

  Scenario: List user sets
    Given I have a set with name "Dogs and cats" with the set items:
      | record_id | position  |
      | 78        | 1         |
      | 79        | 2         |
    When I request my sets
    Then the JSON at "sets" should be a array
    And the JSON at "sets/0/id" should be a string
    And the JSON at "sets/0/name" should be "Dogs and cats"
    And the JSON at "sets/0/count" should be 2
  
  Scenario: Delete a set
    Given I have a set with name "Dogs and cats"
    When I issue a delete request for the set   
    Then I should have 0 sets
