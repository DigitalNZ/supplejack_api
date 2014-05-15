# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Feature: Manage Partners

  Scenario: Create a new partner
    When I create a partner with the JSON:
      """
        {
          "partner": {
            "name": "Public Address"
          }
        }
      """
    Then there should be a partner called "Public Address"

  Scenario: Create an existing partner
    Given I create a partner with the JSON:
      """
        {
          "partner": {
            "_id": "5227ff3f5ea13a50ce000008",
            "name": "Public Address"
          }
        }
      """
    Then there should be a partner called "Public Address"
    When I create a partner with the JSON:
      """
        {
          "partner": {
            "_id": "5227ff3f5ea13a50ce000008",
            "name": "Te Papa"
          }
        }
      """
    Then the partner with id "5227ff3f5ea13a50ce000008" should be called "Te Papa"


  Scenario: Get a partner
    Given a partners exists named "Down to the wire"
    When I get the partner
    Then the JSON should have "_id"
    And the JSON at "name" should be "Down to the wire"

  Scenario: List all partners
    Given these partners exist:
      | name |
      | Down to the wire |
      | Public Address |
    When I list the partners
    Then the JSON at "partners" should have 2 entries
    And the JSON at "partners/0/name" should be "Down to the wire"
    And the JSON at "partners/1/name" should be "Public Address"

  Scenario: Update a parser
    Given a partners exists named "Down to the wire"
    When I update the partner with:
    """
      {
        "partner": {
          "name": "Public Address"
        }
      }
    """
    Then there should be a partner called "Public Address"