Feature: Get Record

	Background:
	Given a user with a API Key
	
	Scenario: List records
		Given these Records:
			| name        | address    | email             | age | children | nz_citizen |
			| John Doe    | Wellington | john@example.com  | 30  | Sally    | true       |
			| Sally Smith | Auckland   | sally@example.com | 22  | James    | true       |
		When I visit index page for the record
		# Then the JSON at "search/results_count" should be 2

	Scenario: Show record
		Given a record
		When I get a record
		Then the JSON should have "record/name"
		And the JSON should have "record/address"
		And the JSON should have "record/email"
		And the JSON should have "record/children"
		And the JSON should have "record/nz_citizen"
		And the JSON should have "record/birthdate"
		And the JSON should have "record/age"


