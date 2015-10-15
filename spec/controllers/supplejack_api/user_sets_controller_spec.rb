# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UserSetsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    before(:each) do
      @user = FactoryGirl.create(:user, authentication_token: "abc123")
      allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
      allow(controller).to receive(:authenticate_user!) { true }
      allow(controller).to receive(:current_user) { @user }
    end

    describe "GET 'index'" do
      before(:each) do
        @sets = [FactoryGirl.build(:user_set)]
      end

      it "should return all the user's sets" do
        expect(controller.current_user).to receive(:user_sets){@sets}
        get :index
      end
    end

    describe "GET 'admin_index'" do
      context "authentication succeeded" do
        before :each do
          allow(controller).to receive(:authenticate_admin!) { true }
          @normal_user = double(User, user_sets: []).as_null_object
          allow(User).to receive(:find_by_api_key).with("nonadminkey") { @normal_user }
        end

        it "authenticates the user as an admin" do
          expect(controller).to receive(:authenticate_admin!) { true }
          get :admin_index, user_id: "nonadminkey"
        end

        it "finds the user from the :user_id" do
          expect(User).to receive(:find_by_api_key).with("nonadminkey")
          get :admin_index, user_id: "nonadminkey"
        end

        it "assigns the user's sets to @user_sets" do
          expect(@normal_user).to receive(:user_sets) { [] }
          get :admin_index, user_id: "nonadminkey"
          expect(assigns(:user_sets)).to eq []
        end

        it "renders a error when the user is not found" do
          allow(User).to receive(:find_by_api_key) { nil }
          get :admin_index, user_id: "whatever"
          expect(response.code).to eq "404"
          expect(response.body).to eq({errors: "The user with api key: 'whatever' was not found"}.to_json)
        end
      end

      context "authentication fails" do
        it "renders a error when the admin authentication fails" do
          allow(controller).to receive(:current_user) { double(:developer, admin?: false, role: 'developer') }
          get :admin_index, user_id: "nonadminkey", format: "json"
          expect(response.code).to eq "403"
          expect(response.body).to eq({errors: "You need Administrator privileges to perform this request"}.to_json)
        end
      end
    end

    describe "#public_index" do
      context "authentication succedded" do
        before :each do
          allow(controller).to receive(:authenticate_admin!) { true }
          @admin_user = double(User).as_null_object
          allow(controller).to receive(:current_user) { @admin_user }
        end

        it "finds all public sets" do
          expect(UserSet).to receive(:public_sets).with(page: nil) { [] }
          get :public_index, format: "json"
        end
      end
    end

    describe "#featured_sets_index" do
      context "authentication succedded" do
        before :each do
          allow(controller).to receive(:authenticate_admin!) { true }
          @admin_user = double(User).as_null_object
          allow(controller).to receive(:current_user) { @admin_user }
        end

        it "finds 4 public sets" do
          expect(UserSet).to receive(:featured_sets).with(4) { [] }
          get :featured_sets_index, format: "json"
        end
      end
    end

    describe "GET 'show'" do
      before(:each) do
        @user_set = FactoryGirl.build(:user_set)
      end

      it "finds the @user_set" do
        expect(UserSet).to receive(:custom_find).with(@user_set.id.to_s) { @user_set }
        get :show, id: @user_set.id.to_s
      end

      it "returns a 404 error when the set is not found" do
        allow(UserSet).to receive(:custom_find) { nil }
        get :show, id: @user_set.id.to_s
        expect(response.code).to eq("404")
        expect(response.body).to eq({errors: "Set with id: #{@user_set.id.to_s} was not found."}.to_json)
      end
    end

    describe "POST 'create'" do
      before(:each) do
        @user_set = FactoryGirl.build(:user_set)
        allow(controller.current_user.user_sets).to receive(:build) { @user_set }
        create(:record, record_id: 12345)
        allow(@user_set).to receive(:set_items).and_return(double(first: double(record_id: 12345)))
      end

      it "should build a new set with the params" do
        expect(controller.current_user.user_sets).to receive(:build) { @user_set }
        expect(@user_set).to receive(:update_attributes_and_embedded).with({"name" => "Dogs", "description" => "Ugly", "privacy" => "hidden"})
        post :create, set: {"name" => "Dogs", "description" => "Ugly", "privacy" => "hidden"}
      end

      it "saves the user set" do
        pending # This is broken because it doesn't create sets properly and I don't know how to make it create sets properly
        expect(@user_set).to receive(:save).and_return(true)
        post :create, set: {}
      end

      it "returns a 422 error when the set is invalid" do
        allow(@user_set).to receive(:update_attributes_and_embedded) { false }
        allow(@user_set).to receive(:errors).and_return({name: ["can't be blank"]})
        post :create, set: {}
        expect(response.code).to eq("422")
        expect(response.body).to eq({errors: {name: ["can't be blank"]}}.to_json)
      end

      it "rescues from a :records format error and renders the error" do
        allow(@user_set).to receive(:update_attributes_and_embedded).and_raise(UserSet::WrongRecordsFormat)
        post :create, set: {}
        expect(response.code).to eq("422")
        expect(response.body).to eq({errors: {records: ["The records array is not in a valid format."]}}.to_json)
      end
    end

    describe "PUT 'update'" do
      before(:each) do
        @user_set = FactoryGirl.create(:user_set, user_id: @user.id)
        allow(@user_set).to receive(:update_attributes_and_embedded) { true }
      end

      context 'normal operations' do
        before(:each) do
          allow(controller.current_user.user_sets).to receive(:custom_find) { @user_set }
        end

        it "finds the @user_set through the user" do
          expect(controller.current_user.user_sets).to receive(:custom_find).with(@user_set.id.to_s) { @user_set }
          put :update, id: @user_set.id.to_s, set: {records: [{record_id: 13, position: 2}]}
        end

        it "returns a 404 error when the set is not found" do
          allow(controller.current_user.user_sets).to receive(:custom_find) { nil }
          put :update, id: @user_set.id.to_s
          expect(response.code).to eq("404")
          expect(response.body).to eq({errors: "Set with id: #{@user_set.id.to_s} was not found."}.to_json)
        end

        it "updates the attributes of the @user_set" do
          expect(@user_set).to receive(:update_attributes_and_embedded).with({"records" => [{"record_id" => "13", "position" => "2"}]}, @user)
          put :update, id: @user_set.id.to_s, set: {records: [{record_id: 13, position: 2}]}
        end

        it "updates the approved attribute of a @user_set" do
          expect(@user_set).to receive(:update_attributes_and_embedded).with({"approved" => true}, @user)
          put :update, id: @user_set.id.to_s, set: {approved: true}
        end

        it "returns a 406 error when the set is invalid" do
          allow(@user_set).to receive(:update_attributes_and_embedded) { false }
          allow(@user_set).to receive(:errors).and_return({name: ["can't be blank"]})
          post :update, id: @user_set.id.to_s, set: {name: nil}
          expect(response.code).to eq("422")
          expect(response.body).to eq({errors: {name: ["can't be blank"]}}.to_json)
        end

        it "rescues from a :records format error and renders the error" do
          allow(@user_set).to receive(:update_attributes_and_embedded).and_raise(UserSet::WrongRecordsFormat)
          post :update, id: @user_set.id.to_s, set: {name: nil}
          expect(response.code).to eq("422")
          expect(response.body).to eq({errors: {records: ["The records array is not in a valid format."]}}.to_json)
        end
      end

    end

    describe "DELETE 'destroy'" do
      before(:each) do
        @user_set = FactoryGirl.create(:user_set, user_id: @user.id)
        allow(controller.current_user.user_sets).to receive(:custom_find) { @user_set }
      end

      it "returns a 404 error when the set is not found" do
        allow(controller.current_user.user_sets).to receive(:custom_find) { nil }
        delete :destroy, id: @user_set.id.to_s
        expect(response.code).to eq("404")
        expect(response.body).to eq({errors: "Set with id: #{@user_set.id.to_s} was not found."}.to_json)
      end

      it "finds the @user_set through the user" do
        expect(controller.current_user.user_sets).to receive(:custom_find).with(@user_set.id.to_s) { @user_set }
        delete :destroy, id: @user_set.id.to_s, format: :json
      end

      it "deletes the user set" do
        expect(@user_set).to receive(:destroy)
        delete :destroy, id: @user_set.id.to_s, format: :json
      end
    end
  end
end
