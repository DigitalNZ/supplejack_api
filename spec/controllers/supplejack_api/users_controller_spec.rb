# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe UsersController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    context 'when user is admin' do
      let(:user) { create(:admin_user) }

      describe 'GET show' do
        it 'should assign @user' do
          get :show, params:  { id: user.id, api_key: user.authentication_token }, format: :json
          expect(assigns(:user)).to eq(user)
        end
      end

      describe 'POST create' do
        it 'should create a new user' do
          allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
          expect(User).to receive(:create).with({ 'name' => 'Ben' }).and_return(user)

          post :create, params: { api_key: user.authentication_token, user: { name: 'Ben' } }, format: 'json'
        end
      end

      describe 'PUT update' do
        it 'updates the user attributes' do
          user_params = attributes_for(:user, name: 'Richard')
          patch :update, params: { id: user.api_key, api_key: user.authentication_token, user: user_params }
          user.reload
          expect(user.name).to eq 'Richard'
        end
      end

      describe 'DELETE destroy' do
        it 'destroys the user' do
          user.save!
          expect(User.count).to eq 1

          delete :destroy, params: { id: user.id, api_key: user.authentication_token }
          expect(User.count).to eq 0
        end
      end
    end

    context 'when user is not admin' do
      let(:user) { create(:user) }

      describe 'GET show' do
        it 'returns status unauthorized' do
          get :show, params:  { id: user.id, api_key: user.authentication_token }, format: :json

          expect(response).to be_unauthorized
          expect(JSON.parse(response.body)['errors']).to eq I18n.t('errors.requires_admin_privileges')
        end
      end

      describe 'POST create' do
        it 'returns status unauthorized' do
          post :create, params: { api_key: user.authentication_token, user: { name: 'Ben' } }, format: 'json'

          expect(response).to be_unauthorized
          expect(JSON.parse(response.body)['errors']).to eq I18n.t('errors.requires_admin_privileges')
        end
      end

      describe 'PUT update' do
        it 'returns status unauthorized' do
          user_params = attributes_for(:user, name: 'Richard')
          patch :update, params: { id: user.api_key, api_key: user.authentication_token, user: user_params }

          expect(response).to be_unauthorized
          expect(JSON.parse(response.body)['errors']).to eq I18n.t('errors.requires_admin_privileges')
        end
      end

      describe 'DELETE destroy' do
        it 'returns status unauthorized' do
          delete :destroy, params: { id: user.id, api_key: user.authentication_token }

          expect(response).to be_unauthorized
          expect(JSON.parse(response.body)['errors']).to eq I18n.t('errors.requires_admin_privileges')
        end
      end
    end
  end
end
