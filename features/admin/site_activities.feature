# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Feature: Site activities
  
  Background: 
    Given an admin user
    When I visit "/admin/users/sign_in"
    And I enter my admin credentials

  Scenario: Usage by date
    When I click "Usage by date" link
    Then I should see "usage" table