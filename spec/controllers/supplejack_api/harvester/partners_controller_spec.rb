# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Harvester::PartnersController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    context 'with a api_key with harvester role' do
      let(:harvester) { create(:user, role: 'harvester') }

      describe 'POST create' do
        it 'creates a new partner' do
          expect do
            post :create, params: { partner: attributes_for(:partner), api_key: harvester.api_key }
          end.to change { Partner.count }.by 1

          expect(response).to be_successful
        end

        it 'returns the partner' do
          post :create, params: { partner: attributes_for(:partner), api_key: harvester.api_key }

          expect(response.body).to include Partner.last.to_json
        end

        context 'partner already exists' do
          it 'updates the partner' do
            partner = create(:partner, name: 'partner1')
            post :create, params: { partner: { _id: partner.id, name: 'partner2' }, api_key: harvester.api_key }
            partner.reload

            expect(partner.name).to eq 'partner2'
          end
        end
      end

      describe 'GET show' do
        it 'finds the partner by id' do
          expect(Partner).to receive(:find).with('1')
          get :show, params: { id: 1, api_key: harvester.api_key }
        end

        it 'returns the partner' do
          partner = create(:partner)
          get :show, params: { id: partner.id, api_key: harvester.api_key }

          expect(response.body).to eq partner.to_json
        end
      end

      describe 'GET index' do
        it 'return all partners' do
          expect(Partner).to receive(:all)

          get :index, params: { api_key: harvester.api_key }
        end

        it 'returns the partners as a JSON array' do
          partners =  [create(:partner),
                       create(:partner, name: 'Down to the wire')]
          get :index, params: { api_key: harvester.api_key }

          expect(response.body).to eq({ partners: partners }.to_json)
        end
      end

      describe 'PUT update' do
        it 'finds and updates the partner' do
          partner = create(:partner)

          expect do
            put :update, params: { id: partner.id, partner: { name: 'Down to the wire' }, api_key: harvester.api_key }
          end.to change { Partner.last.name }.to 'Down to the wire'
        end
      end
    end

    context 'with api_key without harvester role' do
      let(:user) { create(:user, role: 'admin') }

      describe "POST 'create'" do
        it 'returns forbidden' do
          post :create, params: { partner: attributes_for(:partner), api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end

      describe "PUT 'update'" do
        it 'returns forbidden' do
          put :update, params: { id: 1, partner: { name: 'Down to the wire' }, api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end

      describe "GET 'index'" do
        it 'returns forbidden' do
          get :index, params: { api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end

      describe "GET 'show'" do
        it 'returns forbidden' do
          get :show, params: { id: 1, api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end
    end
  end
end
