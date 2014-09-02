# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Feature: View set information

  Background:
    Given a user with a API Key
    Given a user with a API Key
    And these records:
      | record_id | name         | address            | email                       | age | children   | nz_citizen |
      | 78        | John Doe     | Wellington         | ["john@example.com"]        | 30  | ["Sally"]  | true       |
      | 79        | Sally Smith  | Auckland           | ["sally@example.com"]       | 22  | ["James"]  | true       |
      | 12        | Steve Jobs   | Parker St. Dunedin | ["stevejobs@example.com"]   | 62  | ["Samuel"] | false      |
      | 55        | Peter Parker | Christchruch       | ["peterparker@example.com"] | 42  | ["Lily"]   | false      |
    And I have a set with the following values:
      | field       | value              |
      | name        | Dogs and cats      |
      | description | Ugly dogs and cats |
      | privacy     | hidden             |
      | tag_list    | dogs, cats         |

  Scenario: View set information
    When I request the set information
    Then the JSON at "set/name" should be "Dogs and cats"
    And the JSON at "set/description" should be "Ugly dogs and cats"
    And the JSON at "set/privacy" should be "hidden"
    And the JSON at "set/count" should be 0
    And the JSON at "set/tags" should be a array
    And the JSON at "set/tags/0" should be "dogs"
    And the JSON at "set/tags/1" should be "cats"

  Scenario: View set items
    Given the set has the following items:
      | record_id  | position |
      | 12         | 2        |
      | 78         | 1        |
    When I request the set information
    And the JSON at "set/records" should be a array
    And the JSON at "set/records/0/record_id" should be 78
    And the JSON at "set/records/0/position" should be 1
    And the JSON at "set/records/0/name" should be "John Doe"
    And the JSON at "set/records/0/address" should be "Wellington"
    And the JSON at "set/records/1/record_id" should be 12





