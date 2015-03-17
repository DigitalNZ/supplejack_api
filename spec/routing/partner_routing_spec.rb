# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe "Partner routes", type: :routing do
    routes { SupplejackApi::Engine.routes }

    before(:each) do
      allow_any_instance_of(HarvesterConstraint).to receive(:matches?).and_return(true)
    end

    it "routes /partners to partners#create" do
      expect(post("/partners")).to route_to(controller: 'supplejack_api/partners', action: 'create')
    end

    it "routes /partners/1 to partners#show" do
      expect(get("/partners/1")).to route_to(controller: 'supplejack_api/partners', action: 'show', id: '1')
    end

    it "routes /partners to partners#index" do
      expect(get("/partners")).to route_to(controller: 'supplejack_api/partners', action: 'index')
    end

    it "routes /partners/1 to partners#update" do
      expect(put("/partners/1")).to route_to(controller: 'supplejack_api/partners', action: 'update', id: '1')
    end
  end
end
