@search
Feature: Search

  Background:
    Given a user with a API Key
    And these records:
      | name         | address            | email                       | age | children   | nz_citizen |
      | John Doe     | Wellington         | ["john@example.com"]        | 30  | ["Sally"]  | true       |
      | Sally Smith  | Auckland           | ["sally@example.com"]       | 22  | ["James"]  | true       |
      | Steve Jobs   | Parker St. Dunedin | ["stevejobs@example.com"]   | 62  | ["Samuel"] | false      |
      | Peter Parker | Christchruch       | ["peterparker@example.com"] | 42  | ["Lily"]   | false      |
  
  Scenario Outline: Find records by term and return JSON
    When I search for "<name>"
    Then the JSON at "search/results/0/name" should be "<name>"
    And the JSON at "search/results" should have <num results> entries
    
    Examples:
      | term  | name         | num results |
      | john  | John Doe     | 1           |
      | steve | Steve Jobs   | 1           |
      | james | Sally Smith  | 1           |
      | Lily  | Peter Parker | 1           |

  Scenario: Search all records
    When I visit index page for the record
    Then the JSON at "search/result_count" should be 4
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
    When I search for "Wellington OR Auckland"
    Then the JSON at "search/result_count" should be 2
    And the JSON at "search/results/0/name" should be "John Doe"
    And the JSON at "search/results/1/name" should be "Sally Smith"

  Scenario: Scenario: Search for a record using the NOT operator
    When I search for "parker NOT steve"
    Then the JSON at "search/result_count" should be 1
    And the JSON at "search/results/0/name" should be "Peter Parker"

  Scenario: Search for a record targeting a specific field
    # When I search for a field "email_sm:\"sally@example.com\""
    # Then the JSON at "search/result_count" should be 1
    # And the JSON at "search/results/0/email" should be "sally@example.com"

  Scenario: Should not search for the term in other fields
    When I search for a field "email_sm:\"Sally\""
    Then the JSON at "search/result_count" should be 0

  Scenario: Return facets in JSON format
    When I search for "John" with facet "name"
    Then the JSON at "search/facets" should be:
    """
      {
        "name": {
          "John Doe": 1
        }
      }
    """
  Scenario: Return facets in XML format
    When I request a XML format
    And I search for "Auckland" with facet "address"
    Then the response should include the following XML
    """
      <search>
        <facets type="array">
          <facet>
            <name>address</name>
            <values type="array">
              <value>
                <name>Auckland</name>
                <count type="integer">1</count>
              </value>
            </values>
          </facet>
        </facet>
      </search>
    """

