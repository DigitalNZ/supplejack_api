# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Feature: Manage fragments

  Background:
    Given a record

  Scenario: Create a source
    When I post a request to create a fragment with the JSON:
    """
    {
      "fragment": {
        "source_id": "nz-census-2014",
        "name": "John Smith",
        "email": "john.smith@example.com",
        "priority": [1]
      }
    }
    """
    Then the record should have a fragment with the source id "nz-census-2014" and the attributes:
      | name       | email                   | priority |
      | John Smith | john.smith@example.com  | 1        |

  Scenario: Update a fragment
    Given a fragment with source id of "nz-census-2014" and the attributes:
      | name       | email                  |
      | John Smith | john.smith@example.com |
      
    When I post a request to update a fragment with the JSON:
    """
    {
      "fragment": {
        "source_id": "nz-census-2015",
        "name": "John Smith",
        "email": "john.smith@example.com",
        "priority": [2]
      }
    }
    """
    Then the record should have a fragment with the source id "nz-census-2015" and the attributes:
      | name       | email                   | priority |
      | John Smith | john.smith@example.com  |  2       |
    And the record should have 2 fragments