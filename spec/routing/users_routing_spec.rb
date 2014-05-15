# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe "User routes" do
    routes { SupplejackApi::Engine.routes }

    it "routes /users/1.format to users#show" do
      get('/users/1.json').should route_to(controller: 'supplejack_api/users', action: 'show', format: 'json', id: '1')
    end
  end
end
