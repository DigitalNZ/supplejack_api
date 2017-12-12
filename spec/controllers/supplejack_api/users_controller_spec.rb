# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UsersController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    context 'admin user' do
      let(:user) { create(:admin_user, authentication_token: 'abc123') }

      describe 'GET show' do
        it 'should assign @user' do
          get :show, params:  {id: user.id, api_key: 'abc123'}, format: :json
          expect(assigns(:user)).to eq(user)
        end
      end

      describe 'POST create' do
        it 'should create a new user' do
          allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
          expect(User).to receive(:create).with({ 'name' => 'Ben' }).and_return(user)
          post :create, params: {api_key: 'abc123', user: { name: 'Ben' }}, format: 'json'
        end
      end

      describe 'PUT update' do
        it 'updates the user attributes' do
          user_params = attributes_for(:user, name: 'Richard')
          patch :update, params: {id: user.api_key, api_key: user.authentication_token, user: user_params}
          user.reload
          expect(user.name).to eq 'Richard'
        end
      end

      describe 'DELETE destroy' do
        it 'destroys the user' do
          user.save!
          expect(User.count).to eq 1

          delete :destroy, params: {id: user.id, api_key: user.authentication_token}
          expect(User.count).to eq 0
        end
      end
    end

    context 'not an admin user' do
      let(:user) { create(:user, authentication_token: 'abc123') }

      describe 'GET show' do
        it 'returns status forbidden' do
          get :show, params:  {id: user.id, api_key: 'abc123'}, format: :json
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe 'POST create' do
        it 'returns status forbidden' do
          post :create, params: {api_key: 'abc123', user: { name: 'Ben' }}, format: 'json'
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe 'PUT update' do
        it 'returns status forbidden' do
          user_params = attributes_for(:user, name: 'Richard')
          patch :update, params: {id: user.api_key, api_key: user.authentication_token, user: user_params}
          expect(response).to have_http_status(:forbidden)
        end
      end

      describe 'DELETE destroy' do
        it 'returns status forbidden' do
          delete :destroy, params: {id: user.id, api_key: user.authentication_token}
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
