Feature: Authenticate with an API Key
  
  Background: 
    Given a user with a API Key
    
  Scenario: Successfull authentication
    When the user requests an API resource with his API key
    Then the request is successful
    
  Scenario: Wrong api key
    When the user requests an API resource with an invalid API key
    Then she should see the error: "Invalid API Key"
    
  Scenario: Over the max daily requests
    And the user has reached its daily requests limit
    When the user requests an API resource with his API key
    Then she should see the error: "You have reached your maximum number of api requests today"
    
  Scenario: Increment daily requests count
    When the user requests an API resource with his API key
    Then she should have incremented its daily requests by one
    
  