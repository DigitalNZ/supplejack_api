# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

@search
Feature: Get Record

	Background:
		Given a user with a API Key

	Scenario: Show record
		Given a record
		When I get a record
		Then the JSON at "record" should be an hash
		And the JSON at "record/name" should be "John Doe"
		And the JSON at "record/address" should be "Wellington"
		And the JSON at "record/email" should be ["johndoe@example.com"]
		And the JSON at "record/children" should be ["Sally Doe", "James Doe"]	
		And the JSON at "record/age" should be 30
		And the JSON response should have "record/birth_date"
		And the JSON at "record/nz_citizen" should be true