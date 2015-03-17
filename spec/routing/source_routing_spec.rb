# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe 'Source routes', type: :routing do
    routes { SupplejackApi::Engine.routes }

    before(:each) do
      allow_any_instance_of(HarvesterConstraint).to receive(:matches?).and_return(true)
    end

    it 'routes /partners/123/sources to sources#create' do
      expect(post('/partners/123/sources.json')).to route_to(controller: 'supplejack_api/sources', action: 'create', partner_id: '123', format: 'json')
    end

    it 'routes /sources/1234 to sources#show' do
      expect(get('/sources/1234.json')).to route_to(controller: 'supplejack_api/sources', action: 'show', id: '1234', format: 'json')
    end

    it "routes /sources to sources#index" do
      expect(get('/sources.json')).to route_to(controller: 'supplejack_api/sources', action: 'index', format: 'json')
    end

    it "routes /sources/1234 to sources#update" do
      expect(put('/sources/1234.json')).to route_to(controller: 'supplejack_api/sources', action: 'update', id: '1234', format: 'json')
    end

    it "routes /sources/1234/reindex to sources#reindex" do
     expect(get('/sources/1234/reindex.json')).to route_to(controller: 'supplejack_api/sources', action: 'reindex', id: '1234', format: 'json')
    end
  end
end
