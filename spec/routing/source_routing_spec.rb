require 'spec_helper'

module SupplejackApi
  describe 'Source routes' do
    routes { SupplejackApi::Engine.routes }

    before(:each) do
      HarvesterConstraint.any_instance.should_receive(:matches?).and_return(true)
    end
    
    it 'routes /partners/123/sources to sources#create' do
      post('/partners/123/sources.json').should route_to(controller: 'supplejack_api/sources', action: 'create', partner_id: '123', format: 'json')
    end

    it 'routes /sources/1234 to sources#show' do
      get('/sources/1234.json').should route_to(controller: 'supplejack_api/sources', action: 'show', id: '1234', format: 'json')
    end

    it "routes /sources to sources#index" do
      get('/sources.json').should route_to(controller: 'supplejack_api/sources', action: 'index', format: 'json')
    end

    it "routes /sources/1234 to sources#update" do
      put('/sources/1234.json').should route_to(controller: 'supplejack_api/sources', action: 'update', id: '1234', format: 'json')
    end

    it "routes /sources/1234/reindex to sources#reindex" do
     get('/sources/1234/reindex.json').should route_to(controller: 'supplejack_api/sources', action: 'reindex', id: '1234', format: 'json')
    end
  end
end
