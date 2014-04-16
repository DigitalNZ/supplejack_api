@search
Feature: Search

	Background:
		Given a user with a API Key
		And these Records:
			| name        | address    | email                 | age | children  | nz_citizen |
			| John Doe    | Wellington | ["john@example.com"]  | 30  | ["Sally"] | true       |
			| Sally Smith | Auckland   | ["sally@example.com"] | 22  | ["James"] | true       |
	
	# Scenario Outline: Find records by term and return JSON

	Scenario: Search all records
		When I visit index page for the record
		Then the JSON at "search/result_count" should be 2
		And the JSON at "search/results" should be an array
		And the JSON at "search/per_page" should be 20
		And the JSON at "search/page" should be 1
		And the JSON at "search/request_url" should be the requested url

	Scenario: Search for a record
		When I search for "Auckland"
    Then the JSON at "search/results" should be an array
    And the JSON at "search/facets" should be an hash
    And the JSON at "search/result_count" should be 1
    And the JSON at "search/per_page" should be 20
    And the JSON at "search/page" should be 1
    And the JSON at "search/request_url" should be the requested url

	Scenario: Search for a record using the OR operator
		# When I search for "Wellington OR Auckland"
  #   Then the JSON at "search/result_count" should be 2
  #   And the JSON at "search/results/0/name" should be "John Doe"
  #   And the JSON at "search/results/1/name" should be "Sally Smith"

	Scenario: Scenario: Search for a record using the NOT operator

	Scenario: Search for a record targeting a specific field
		# When I search for a field "email_sm:\"sally@example.com\""
  #   Then the JSON at "search/result_count" should be 1
  #   And the JSON at "search/results/0/email" should be "sally@example.com"

	Scenario: Should not search for the term in other fields
	Scenario: Return facets in JSON format
	Scenario: Return facets in XML format

