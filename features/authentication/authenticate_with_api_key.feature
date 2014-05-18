# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
    
  