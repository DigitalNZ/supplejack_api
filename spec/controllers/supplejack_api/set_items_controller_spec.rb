# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SetItemsController do
    routes { SupplejackApi::Engine.routes }
    
    before {
      @user = FactoryGirl.create(:user, authentication_token: "abc123")
      controller.stub(:authenticate_user!) { true }
      controller.stub(:current_user) { @user }
      @user_set = FactoryGirl.create(:user_set)
      controller.current_user.user_sets.stub(:custom_find) { @user_set }
      @set_item = double(:set_item).as_null_object
    }

    describe "POST 'create'" do
      it 'creates the set item through the @user_set' do
        @user_set.set_items.should_receive(:build).with({'record_id' => '2'}) { @set_item }
        @user_set.should_receive(:save)
        post :create, user_set_id: @user_set.id, record: { record_id: 2 }
      end
    end

    describe "DELETE 'destroy'" do
      before(:each) do
        @user_set.set_items.stub(:find_by_record_id) { @set_item }
      end

      it 'finds the @set_item through the user_set' do
        @user_set.set_items.should_receive(:find_by_record_id).with('12')
        delete :destroy, user_set_id: @user_set.id, id: '12'
      end

      it 'destroys the @set_item' do
        @set_item.should_receive(:destroy)
        delete :destroy, user_set_id: @user_set.id, id: '12'
      end

      context 'it doesn\'t find the set_item' do
        before(:each) do
          @user_set.set_items.stub(:find_by_record_id) { nil }
        end

        it 'returns a 404' do
          delete :destroy, user_set_id: @user_set.id, id: '12'
          response.code.should eq '404'
          response.body.should eq({errors: 'The record with id: 12 was not found.'}.to_json)
        end
      end
    end

  end
end