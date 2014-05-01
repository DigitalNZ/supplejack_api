require 'spec_helper'

module SupplejackApi
  describe "Harvester routes" do
    routes { SupplejackApi::Engine.routes }

    before(:each) do
      HarvesterConstraint.any_instance.should_receive(:matches?).and_return(true)
    end

    context "Record routes" do
      it "routes /harvester/records to harvester/records#create" do
        post('/harvester/records.json').should route_to(controller: 'supplejack_api/harvester/records', action: 'create', format: 'json')
      end

      it "routes /harvester/records/1 to harvester/records#show" do
        get('/harvester/records/1.json').should route_to(controller: 'supplejack_api/harvester/records', action: 'show', id: '1', format: 'json')
      end

      it "routes /harvester/records/1 to harvester/records#update" do
        put('/harvester/records/1.json').should route_to(controller: 'supplejack_api/harvester/records', action: 'update', id: '1', format: 'json')
      end

      it "routes /harvester/records/flush to harvester/records#flush" do
        post('/harvester/records/flush').should route_to('supplejack_api/harvester/records#flush')
      end

      it "routes /harvester/records/abc123 to harvester/records#delete" do
        put('/harvester/records/delete').should route_to('supplejack_api/harvester/records#delete')
      end
    end

    context "Fragment routes" do
    	it "routes /harvester/records/1/fragments.json to harvester/fragments#create" do
    	  post('/harvester/records/1/fragments.json').should route_to('supplejack_api/harvester/fragments#create', record_id: '1', format: 'json')
    	end

      it "routes /harvester/fragments/1.json to harvester/fragments#destroy" do
        delete('/harvester/fragments/1.json').should route_to('supplejack_api/harvester/fragments#destroy', id: '1', format: 'json')
      end
    end

  end
end
