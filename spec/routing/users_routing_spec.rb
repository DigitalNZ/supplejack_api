require 'spec_helper'

module SupplejackApi
  describe "User routes" do
    routes { SupplejackApi::Engine.routes }

    it "routes /users/1.format to users#show" do
      get('/users/1.json').should route_to(controller: 'supplejack_api/users', action: 'show', format: 'json', id: '1')
    end
  end
end
