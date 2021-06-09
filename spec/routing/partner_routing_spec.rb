# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe 'Partner routes', type: :routing do
    routes { SupplejackApi::Engine.routes }

    it 'routes /harvester/partners to partners#create' do
      expect(post('/harvester/partners')).to route_to(controller: 'supplejack_api/harvester/partners', action: 'create')
    end

    it 'routes /harvester/partners/1 to partners#show' do
      expect(get('/harvester/partners/1')).to route_to(controller: 'supplejack_api/harvester/partners', action: 'show', id: '1')
    end

    it 'routes /harvester/partners to partners#index' do
      expect(get('/harvester/partners')).to route_to(controller: 'supplejack_api/harvester/partners', action: 'index')
    end

    it 'routes /harvester/partners/1 to partners#update' do
      expect(put('/harvester/partners/1')).to route_to(controller: 'supplejack_api/harvester/partners', action: 'update', id: '1')
    end
  end
end
