require 'spec_helper'

module SupplejackApi
  describe 'Records route' do
    routes { SupplejackApi::Engine.routes }

    it 'routes /status to records#status' do
    	expect(get '/status').to route_to controller: 'supplejack_api/records', action: 'status'
    end

    it 'routes /records.format to records#index' do
    	expect(get '/records.json').should route_to(controller: 'supplejack_api/records', action: 'index', format: 'json')
    end

    it 'routes /records/1.format to records#index' do
    	expect(get '/records/99.json').should route_to(controller: 'supplejack_api/records', action: 'show', id: '99', format: 'json')
    end
  end
end
