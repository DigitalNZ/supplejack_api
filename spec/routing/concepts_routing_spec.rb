# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe 'Concepts route', type: :routing do
    routes { SupplejackApi::Engine.routes }

    it 'routes /concepts/1.format to concepts#index' do
      expect(get '/concepts/1.json').to route_to(controller: 'supplejack_api/concepts', action: 'show', id: '1', format: 'json', version: nil)
    end

    it 'routes /concepts/1/records.format to records#index' do
      expect(get '/concepts/1/records.json').to route_to(version: nil, format: 'json', on: :member, controller: 'supplejack_api/records', action: 'index', concept_id: '1')
    end
  end
end
