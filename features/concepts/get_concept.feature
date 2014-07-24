# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

@search
Feature: Get Concept

	Background:
		Given a user with a API Key
		And a concept

	Scenario: Show concept
		When I get a concept
		Then the JSON should be a hash
		And the JSON at "label" should be "Colin McCahon"

	Scenario: Get specific field
		When I get a concept with "label" field
		Then the JSON should have 2 keys
		And the JSON at "label" should be "Colin McCahon"
		And the JSON at "@context" should be:
		"""
      {
        "label": "skos:prefLabel",
      	"skos": "http://www.w3.org/2004/02/skos/core"
      }
    """
