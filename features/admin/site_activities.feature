

Feature: Site activities
  
  Background: 
    Given an admin user
    When I visit "/admin/users/sign_in"
    And I enter my admin credentials

  Scenario: Usage by date
    When I click "Usage by date" link
    Then I should see "usage" table