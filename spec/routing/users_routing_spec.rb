# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe "User routes", type: :routing do
    routes { SupplejackApi::Engine.routes }

    it "routes /users/1.format to users#show" do
      expect(get('/users/1.json')).to route_to(controller: 'supplejack_api/users', action: 'show', format: 'json', id: '1')
    end
  end
end
