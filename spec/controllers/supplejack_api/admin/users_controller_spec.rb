# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  module Admin
    describe UsersController, type: :controller do
      routes { SupplejackApi::Engine.routes }
      
      let(:user) { double(User).as_null_object }

      before(:each) do
        allow(controller).to receive(:current_admin_user) { user }
        allow(controller).to receive(:authenticate_admin_user!) { true }
      end

      describe 'GET index' do
        before { allow(User).to receive(:sortable) { [user] } }

        it 'finds all the users' do
          get :index
          expect(assigns(:users)).to eq [user]
        end

        it 'sorts the users by the order param' do
          expect(User).to receive(:sortable).with(hash_including(order: 'name_asc'))
          get :index, order: 'name_asc'
        end

        it 'paginates the users' do
          expect(User).to receive(:sortable).with(hash_including(page: '2'))
          get :index, page: 2
        end
      end

      describe 'GET edit' do
        it 'finds the user by id' do
          expect(User).to receive(:find).with('1') { user }
          get :edit, id: 1
          expect(assigns(:user)).to eq user
        end
      end

      describe 'PUT update' do 
        before(:each) do
          allow(User).to receive(:find) {user}
        end

        it 'finds the user by id' do
          expect(User).to receive(:find).with('1') { user }
          put :update, id: 1, user: {max_requests: 1000}
          expect(assigns(:user)).to eq user
        end

        it 'trys to update attributes on user' do
          expect(user).to receive(:update_attributes).with('max_requests' => '1000')
          put :update, id: 1, user: {max_requests: 1000}
        end

        it 'renders edit if attributes are invalid' do
          allow(user).to receive(:update_attributes) {false}
          put :update, id: 1, user: {max_requests: -1000}
          expect(response).to render_template('admin/users/edit')
        end

        it 'redirects to admin_users_path if attributes are valid' do
          allow(user).to receive(:update_attributes) {true}
          put :update, id: 1, user: {max_requests: 1000}
          expect(response).to redirect_to admin_users_path
        end
      end
    end
  end
end
