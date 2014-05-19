# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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