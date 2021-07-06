# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe 'Records route', type: :routing do
    routes { SupplejackApi::Engine.routes }

    it 'routes /records.format to records#index' do
      expect(get: '/records.json')
        .to route_to(controller: 'supplejack_api/records', action: 'index', format: 'json', version: nil)
    end

    it 'routes /records/:id.format to records#index' do
      expect(get: '/records/99.json')
        .to route_to(controller: 'supplejack_api/records', action: 'show', id: '99', format: 'json', version: nil)
    end

    it 'routes /records/multiple.json to records#multiple' do
      expect(get: '/records/multiple.json')
        .to route_to(controller: 'supplejack_api/records', action: 'multiple', format: 'json', version: nil)
    end

    it 'routes /records/:record_id/more_like_this.json to records#more_like_this' do
      expect(get: '/records/1/more_like_this.json')
        .to route_to(controller: 'supplejack_api/records', action: 'more_like_this',
                     record_id: '1', format: 'json', version: nil)
    end
  end
end
