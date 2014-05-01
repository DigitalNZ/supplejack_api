Feature: Manage records

  Scenario: Create record without priority
    When I post a request to create a record with the JSON:
    """
    {
      "record": {
        "source_id": "nz-census-2014",
        "internal_identifier": "abc123",
        "name": "John Smith" 
      }
    }
    """
    Then there should be a new record with the identifier "abc123"
    And the record should have a fragment with the source id "nz-census-2014" and the attributes:
      | name       | priority |
      | John Smith | 0        |


   Scenario: Create record with priority
    When I post a request to create a record with the JSON:
    """
    {
      "record": {
        "source_id": "nz-census-2014",
        "internal_identifier": "abc123",
        "name": "John Smith",
        "priority": -10
      }
    }
    """
    Then there should be a new record with the identifier "abc123"
    And the record should have a fragment with the source id "nz-census-2014" and the attributes:
      | name       | priority |
      | John Smith | -10      |


    @focus
    Scenario: Set record-level attributes on new record
    When I post a request to create a record with the JSON:
    """
    {
      "record": {
        "source_id": "nz-census-2014",
        "internal_identifier": "abc123",
        "name": "John Smith",
        "priority": -10,
        "landing_url": "http://nz-census-2014.govt.nz/"
      }
    }
    """
    Then the record with the identifier "abc123" should have status "active"
    And the record should have attributes:
      | landing_url                    |
      | http://nz-census-2014.govt.nz/ |
    And the record should have a fragment with the source id "nz-census-2014" and the attributes:
      | name       |
      | John Smith |


  Scenario: Update a record
    Given a record with the identifier "abc123"
    And a fragment with source id of "nz-census-2014" and the attributes:
      | name       | age | priority |
      | John Smith | 15  | 0        |
    When I post a request to update a record with the JSON:
    """
    {
      "record": {
        "source_id": "nz-census-2014",
        "internal_identifier": "abc123",
        "landing_url": "http://nz-census-2014.govt.nz/",
        "name": "Bob Jones",
        "age": "20"
      }
    }
    """
    Then the record should have a fragment with the source id "nz-census-2014" and the attributes:
      | name       | age | priority |
      | Bob Jones  | 20  | 0        |
    And the record should have 1 fragment


  Scenario: Flush records
    Given a record with the identifier "abc123"
    And a fragment with source id of "nz-census-2014" and the attributes:
      | title | job_id | priority | status |
      | Dogs  | 123    | 0        | active |
    And a record with the identifier "some-other-unique-id"
    And a fragment with source id of "nz-census-2014" and the attributes:
      | title | job_id | priority | status |
      | Cats  | abc    | 0        | active |
    When I post a request to flush records with a source_id of "nz-census-2014" and a job_id of "abc"
    Then the record with the identifier "abc123" should have status "deleted"
    And the record with the identifier "some-other-unique-id" should have status "active"

  Scenario: Mark a record as 'deleted'
    Given a record with the identifier "abc123"
    When I send a put request to mark the record as deleted with the identifier "abc123"
    Then the status of the record should be "deleted"
