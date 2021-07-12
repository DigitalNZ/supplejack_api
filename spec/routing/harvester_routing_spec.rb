# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe 'Harvester routes', type: :routing do
    routes { SupplejackApi::Engine.routes }

    context 'Record routes' do
      it 'routes /harvester/records to harvester/records#create' do
        expect(post: '/harvester/records.json')
          .to route_to(controller: 'supplejack_api/harvester/records',
                       action: 'create',
                       format: 'json')
      end

      it 'routes /harvester/records/1 to harvester/records#show' do
        expect(get: '/harvester/records/1.json')
          .to route_to(controller: 'supplejack_api/harvester/records',
                       action: 'show', id: '1', format: 'json')
      end

      it 'routes /harvester/records/1 to harvester/records#update' do
        expect(put: '/harvester/records/1.json')
          .to route_to(controller: 'supplejack_api/harvester/records',
                       action: 'update', id: '1', format: 'json')
      end

      it 'routes /harvester/records/flush to harvester/records#flush' do
        expect(post: '/harvester/records/flush').to route_to('supplejack_api/harvester/records#flush')
      end

      it 'routes /harvester/records/abc123 to harvester/records#delete' do
        expect(put: '/harvester/records/delete').to route_to('supplejack_api/harvester/records#delete')
      end
    end

    context 'Fragment routes' do
      it 'routes /harvester/records/1/fragments.json to harvester/fragments#create' do
        expect(post: '/harvester/records/1/fragments.json')
          .to route_to('supplejack_api/harvester/fragments#create',
                       record_id: '1', format: 'json')
      end

      it 'routes /harvester/fragments/1.json to harvester/fragments#destroy' do
        expect(delete: '/harvester/fragments/1.json')
          .to route_to('supplejack_api/harvester/fragments#destroy', id: '1', format: 'json')
      end
    end
  end
end
