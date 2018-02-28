

require 'spec_helper'

module SupplejackApi
  describe 'Records route', type: :routing do
    routes { SupplejackApi::Engine.routes }

    it 'routes /records.format to records#index' do
      expect(get '/records.json').to route_to(controller: 'supplejack_api/records', action: 'index', format: 'json', version: nil)
    end

    it 'routes /records/1.format to records#index' do
      expect(get '/records/99.json').to route_to(controller: 'supplejack_api/records', action: 'show', id: '99', format: 'json', version: nil)
    end
    
    it 'routes /records/multiple.json records#multiple' do
      expect(get: '/records/multiple.json').to route_to(controller: 'supplejack_api/records', action: 'multiple', format: 'json', version: nil)
    end
  end
end
