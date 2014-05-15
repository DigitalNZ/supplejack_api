# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

@search
Feature: Spellcheck
  
  Background:
    Given a user with a API Key
    And these records:
      | name        | address    | email                 | age | children  | nz_citizen |
      | John Doe    | Wellington | ["john@example.com"]  | 30  | ["Sally"] | true       |
      | Sally Smith | Auckland   | ["sally@example.com"] | 22  | ["James"] | true       |

  Scenario: Search with suggest
    # When I search for "jahn" with suggest
    # Then the JSON at "search/suggestion" should be "john"

  Scenario: Search without suggest
    # When I search for "jahn"
    # Then the JSON should not have "search/suggestion"
