# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Feature: Manage concepts

	Scenario: Create a concept
		When I post a request to create a concept with the JSON:
		"""
		{
      "concept": {
        "internal_identifier": "abc123",
        "landing_url": "http://nz-census-2014.govt.nz/",
        "concept_type": "people" 
      }
    }
    """
    Then the concept with the identifier "abc123" should have attributes:
    	| landing_url  												|  concept_type |
      | http://nz-census-2014.govt.nz/      |  people				|

   Scenario: Update a concept
   	Given a concept with the identifier "abc123"
	  And a fragment with source id of "nz-census-2014" and the attributes:
      | name       | gender | priority |
      | John Smith | male   | 0        |
    When I post a request to update a concept with the JSON:
    """
    {
      "concept": {
        "source_id": "nz-census-2014",
        "internal_identifier": "abc123",
        "landing_url": "http://nz-census-2014.govt.nz/",
        "name": "Bob Jones",
        "gender": "male"
      }
    }
    """
    Then the concept should have a fragment with the source id "nz-census-2014" and the attributes:
      | name       | gender | priority |
      | Bob Jones  | male   | 0        |
    And the concept should have 1 fragment


      
