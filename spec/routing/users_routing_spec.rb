# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe 'User routes', type: :routing do
    routes { SupplejackApi::Engine.routes }

    it 'routes /users/1.format to users#show' do
      expect(get: '/users/1.json')
        .to route_to(controller: 'supplejack_api/users', action: 'show', format: 'json', id: '1', version: nil)
    end
  end
end
