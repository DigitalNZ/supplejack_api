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
        controller.stub(:current_admin_user) { user }
        controller.stub(:authenticate_admin_user!) { true }
      end

      describe 'GET index' do
        before { User.stub(:sortable) { [user] } }

        it 'finds all the users' do
          get :index
          assigns(:users).should eq [user]
        end

        it 'sorts the users by the order param' do
          User.should_receive(:sortable).with(hash_including(order: 'name_asc'))
          get :index, order: 'name_asc'
        end

        it 'paginates the users' do
          User.should_receive(:sortable).with(hash_including(page: '2'))
          get :index, page: 2
        end
      end

      describe 'GET edit' do
        it 'finds the user by id' do
          User.should_receive(:find).with('1') { user }
          get :edit, id: 1
          assigns(:user).should eq user
        end
      end

      describe 'PUT update' do 
        before(:each) do
          User.stub(:find) {user}
          # allow(User).to receive_messages(find: user)
        end

        it 'finds the user by id' do
          User.should_receive(:find).with('1') { user }
          put :update, id: 1, user: {max_requests: 1000}
          assigns(:user).should eq user
        end

        it 'trys to update attributes on user' do
          user.should_receive(:update_attributes).with('max_requests' => '1000')
          put :update, id: 1, user: {max_requests: 1000}
        end

        it 'renders edit if attributes are invalid' do
          user.stub(:update_attributes) {false}
          put :update, id: 1, user: {max_requests: -1000}
          response.should render_template('admin/users/edit')
        end

        it 'redirects to admin_users_path if attributes are valid' do
          user.stub(:update_attributes) {true}
          put :update, id: 1, user: {max_requests: 1000}
          response.should redirect_to admin_users_path
        end
      end
    end
  end
end
