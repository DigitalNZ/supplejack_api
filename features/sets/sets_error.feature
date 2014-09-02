# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Feature: Sets Errors

  Background:
    Given a user with a API Key

  Scenario: Try to create a set without a name
    When I post a request to create a set with the JSON:
    """
    {
      "set": {
        "privacy": "hidden"
      }
    }
    """
    Then I should have 0 sets