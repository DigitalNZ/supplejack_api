# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SetItemsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    before {
      @user = FactoryGirl.create(:user, authentication_token: "abc123")
      allow(controller).to receive(:authenticate_user!) { true }
      allow(controller).to receive(:current_user) { @user }
      @user_set = FactoryGirl.create(:user_set_with_set_item)
      @set_item = @user_set.set_items.first
      allow(controller.current_user.user_sets).to receive(:custom_find) { @user_set }
    }

    describe "POST 'create'" do
      it 'creates the set item through the @user_set' do
        expect(@user_set.set_items).to receive(:build).with({'record_id' => '2'}) { @set_item }
        expect(@user_set).to receive(:save).and_return(true)
        post :create, user_set_id: @user_set.id, record: { record_id: '2' }, format: :json
      end
    end
    
    describe "DELETE 'destroy'" do
      before(:each) do
        allow(@user_set.set_items).to receive(:find_by_record_id) { @set_item }
      end

      it 'finds the @set_item through the user_set' do
        expect(@user_set.set_items).to receive(:find_by_record_id).with('12')
        delete :destroy, user_set_id: @user_set.id, id: '12', format: :json
      end

      it 'destroys the @set_item' do
        expect(@set_item).to receive(:destroy)
        delete :destroy, user_set_id: @user_set.id, id: '12', format: :json
      end

      context 'it doesn\'t find the set_item' do
        before(:each) do
          allow(@user_set.set_items).to receive(:find_by_record_id) { nil }
        end

        it 'returns a 404' do
          delete :destroy, user_set_id: @user_set.id, id: '12'
          expect(response.code).to eq '404'
          expect(response.body).to eq({errors: 'The record with id: 12 was not found.'}.to_json)
        end
      end
    end

  end
end
