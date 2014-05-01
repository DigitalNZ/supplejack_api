require 'spec_helper'

module SupplejackApi
  describe "Partner routes" do
    routes { SupplejackApi::Engine.routes }

    before(:each) do
      HarvesterConstraint.any_instance.should_receive(:matches?).and_return(true)
    end

    it "routes /partners to partners#create" do
      post("/partners").should route_to(controller: 'supplejack_api/partners', action: 'create')
    end

    it "routes /partners/1 to partners#show" do
      get("/partners/1").should route_to(controller: 'supplejack_api/partners', action: 'show', id: '1')
    end

    it "routes /partners to partners#index" do
      get("/partners").should route_to(controller: 'supplejack_api/partners', action: 'index')
    end

    it "routes /partners/1 to partners#update" do
      put("/partners/1").should route_to(controller: 'supplejack_api/partners', action: 'update', id: '1')
    end
  end
end
