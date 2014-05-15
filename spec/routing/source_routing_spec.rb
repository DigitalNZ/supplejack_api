# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
