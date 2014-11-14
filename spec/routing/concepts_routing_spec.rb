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

    # it 'routes /concepts.format to concepts#index' do
    #   expect(get '/concepts.json').to route_to(controller: 'supplejack_api/concepts', action: 'index', format: 'json')
    # end

    it 'routes /concepts/1.format to concepts#index' do
      expect(get '/concepts/99.json').to route_to(controller: 'supplejack_api/concepts', action: 'show', id: '99', format: 'json')
    end
  end
end
