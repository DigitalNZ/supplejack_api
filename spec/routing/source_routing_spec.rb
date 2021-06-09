# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe 'Source routes', type: :routing do
    routes { SupplejackApi::Engine.routes }

    it 'routes /harvester/partners/123/sources to sources#create' do
      expect(post('/harvester/partners/123/sources.json')).to route_to(controller: 'supplejack_api/harvester/sources', action: 'create', partner_id: '123', format: 'json')
    end

    it 'routes /harvester/sources/1234 to sources#show' do
      expect(get('/harvester/sources/1234.json')).to route_to(controller: 'supplejack_api/harvester/sources', action: 'show', id: '1234', format: 'json')
    end

    it 'routes /harvester/sources to sources#index' do
      expect(get('/harvester/sources.json')).to route_to(controller: 'supplejack_api/harvester/sources', action: 'index', format: 'json')
    end

    it 'routes /harvester/sources/1234 to sources#update' do
      expect(put('/harvester/sources/1234.json')).to route_to(controller: 'supplejack_api/harvester/sources', action: 'update', id: '1234', format: 'json')
    end

    it 'routes /harvester/sources/1234/reindex to sources#reindex' do
     expect(get('/harvester/sources/1234/reindex.json')).to route_to(controller: 'supplejack_api/harvester/sources', action: 'reindex', id: '1234', format: 'json')
    end
  end
end
