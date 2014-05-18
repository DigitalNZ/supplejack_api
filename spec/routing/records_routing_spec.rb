# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe 'Records route' do
    routes { SupplejackApi::Engine.routes }

    it 'routes /status to records#status' do
    	expect(get '/status').to route_to controller: 'supplejack_api/records', action: 'status'
    end

    it 'routes /records.format to records#index' do
    	expect(get '/records.json').to route_to(controller: 'supplejack_api/records', action: 'index', format: 'json')
    end

    it 'routes /records/1.format to records#index' do
    	expect(get '/records/99.json').to route_to(controller: 'supplejack_api/records', action: 'show', id: '99', format: 'json')
    end
  end
end
