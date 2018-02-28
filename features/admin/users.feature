

Feature: Users

	Background: 
    Given an admin user
    When I visit "/admin/users/sign_in"
    And I enter my admin credentials

   Scenario: Users page
   	Then I should see "users" table

   Scenario: Users show page
   	When I click the user's API key
   	Then I should see user's details

   Scenario: Update user's max requests
   	When I click the user's Max Requests
   	And I enter "900" as Max Requests
   	Then I should should see the updated Max Requests
