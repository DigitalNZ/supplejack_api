@search
Feature: Search

	Background:
		Given a user with a API Key
	
	# Scenario Outline: Find records by term and return JSON

	Scenario: Search all records
		Given these Records:
			| name        | address    | email                 | age | children  | nz_citizen |
			| John Doe    | Wellington | ["john@example.com"]  | 30  | ["Sally"] | true       |
			| Sally Smith | Auckland   | ["sally@example.com"] | 22  | ["James"] | true       |
		When I visit index page for the record
		Then the JSON at "search/result_count" should be 2
		And the JSON at "search/results" should be an array
		And the JSON at "search/per_page" should be 20
		And the JSON at "search/page" should be 1
		And the JSON at "search/request_url" should be the requested url

	Scenario: Search for a record
	Scenario: Search for a record using the OR operator
	Scenario: Scenario: Search for a record using the NOT operator
	Scenario: Search for a record targeting a specific field
	Scenario: Should not search for the term in other fields
	Scenario: Return facets in JSON format
	Scenario: Return facets in XML format

