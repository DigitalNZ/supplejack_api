

Feature: Authentication
  
  Background: 
    Given an admin user

  Scenario: Log in
    When I visit "/admin/users/sign_in"
    And I enter my admin credentials
    Then I should signed in successfully

  Scenario: Log out
    When I visit "/admin/users/sign_in"
    And I enter my admin credentials
    And I click "Log out" link
    Then I should signed out successfully