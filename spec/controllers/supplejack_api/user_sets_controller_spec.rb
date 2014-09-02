# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UserSetsController do
    routes { SupplejackApi::Engine.routes }
    
    before(:each) do
      @user = FactoryGirl.create(:user, authentication_token: "abc123")
      controller.stub(:authenticate_user!) { true }
      controller.stub(:current_user) { @user }
    end

    describe "GET 'index'" do
      before(:each) do
        @sets = [double(:set).as_null_object]
      end

      it "should return all the user's sets" do
        controller.current_user.should_receive(:user_sets){@sets}
        get :index
      end
    end

    describe "GET 'admin_index'" do
      context "authentication succedded" do
        before :each do
          controller.stub(:authenticate_admin!) { true }
          @normal_user = mock_model(User, user_sets: []).as_null_object
          User.stub(:find_by_api_key).with("nonadminkey") { @normal_user }
        end

        it "authenticates the user as an admin" do
          controller.should_receive(:authenticate_admin!) { true }
          get :admin_index, user_id: "nonadminkey"
        end

        it "finds the user from the :user_id" do
          User.should_receive(:find_by_api_key).with("nonadminkey")
          get :admin_index, user_id: "nonadminkey"
        end

        it "assigns the user's sets to @user_sets" do
          @normal_user.should_receive(:user_sets) { [] }
          get :admin_index, user_id: "nonadminkey"
          assigns(:user_sets).should eq []
        end

        it "renders a error when the user is not found" do
          User.stub(:find_by_api_key) { nil }
          get :admin_index, user_id: "whatever"
          response.code.should eq "404"
          response.body.should eq({errors: "The user with api key: 'whatever' was not found"}.to_json)
        end
      end

      context "authentication fails" do
        it "renders a error when the admin authentication fails" do
          controller.stub(:current_user) { mock_model(User, :admin? => false) }
          get :admin_index, user_id: "nonadminkey", format: "json"
          response.code.should eq "403"
          response.body.should eq({errors: "You need Administrator privileges to perform this request"}.to_json)
        end
      end
    end

    describe "#public_index" do
      context "authentication succedded" do
        before :each do
          controller.stub(:authenticate_admin!) { true }
          @admin_user = mock_model(User).as_null_object
          controller.stub(:current_user) { @admin_user }
        end

        it "finds all public sets" do
          UserSet.should_receive(:public_sets).with(page: nil) { [] }
          get :public_index, format: "json"
        end
      end
    end

    describe "#featured_sets_index" do
      context "authentication succedded" do
        before :each do
          controller.stub(:authenticate_admin!) { true }
          @admin_user = mock_model(User).as_null_object
          controller.stub(:current_user) { @admin_user }
        end

        it "finds 4 public sets" do
          UserSet.should_receive(:featured_sets).with(4) { [] }
          get :featured_sets_index, format: "json"
        end
      end
    end
    
    describe "GET 'show'" do
      before(:each) do
        @user_set = FactoryGirl.build(:user_set)
      end

      it "finds the @user_set" do
        UserSet.should_receive(:custom_find).with(@user_set.id.to_s) { @user_set }
        get :show, id: @user_set.id.to_s
      end

      it "returns a 404 error when the set is not found" do
        UserSet.stub(:custom_find) { nil }
        get :show, id: @user_set.id.to_s
        response.code.should eq("404")
        response.body.should eq({errors: "Set with id: #{@user_set.id.to_s} was not found."}.to_json)
      end 
    end

    describe "POST 'create'" do
      before(:each) do
        @user_set = FactoryGirl.build(:user_set)
        controller.current_user.user_sets.stub(:build) { @user_set }
      end

      it "should build a new set with the params" do
        controller.current_user.user_sets.should_receive(:build) { @user_set }
        @user_set.should_receive(:update_attributes_and_embedded).with({"name" => "Dogs", "description" => "Ugly", "privacy" => "hidden"})
        post :create, set: {"name" => "Dogs", "description" => "Ugly", "privacy" => "hidden"}
      end

      it "saves the user set" do
        @user_set.should_receive(:save).and_return(true)
        post :create, set: {}
      end

      it "returns a 422 error when the set is invalid" do
        @user_set.stub(:update_attributes_and_embedded) { false }
        @user_set.stub(:errors).and_return({name: ["can't be blank"]})
        post :create, set: {}
        response.code.should eq("422")
        response.body.should eq({errors: {name: ["can't be blank"]}}.to_json)
      end

      it "rescues from a :records format error and renders the error" do
        @user_set.stub(:update_attributes_and_embedded).and_raise(UserSet::WrongRecordsFormat)
        post :create, set: {}
        response.code.should eq("422")
        response.body.should eq({errors: {records: ["The records array is not in a valid format."]}}.to_json)
      end
    end

    describe "PUT 'update'" do
      before(:each) do
        @user_set = FactoryGirl.create(:user_set, user_id: @user.id)
        @user_set.stub(:update_attributes_and_embedded) { true }
        controller.current_user.user_sets.stub(:custom_find) { @user_set }
      end

      it "finds the @user_set through the user" do
        controller.current_user.user_sets.should_receive(:custom_find).with(@user_set.id.to_s) { @user_set }
        put :update, id: @user_set.id.to_s, set: {records: [{record_id: 13, position: 2}]}
      end

      it "returns a 404 error when the set is not found" do
        controller.current_user.user_sets.stub(:custom_find) { nil }
        put :update, id: @user_set.id.to_s
        response.code.should eq("404")
        response.body.should eq({errors: "Set with id: #{@user_set.id.to_s} was not found."}.to_json)
      end

      it "updates the attributes of the @user_set" do
        @user_set.should_receive(:update_attributes_and_embedded).with({"records" => [{"record_id" => "13", "position" => "2"}]}, @user)
        put :update, id: @user_set.id.to_s, set: {records: [{record_id: 13, position: 2}]}
      end

      it "updates the approved attribute of a @user_set" do
        @user_set.should_receive(:update_attributes_and_embedded).with({"approved" => true}, @user)
        put :update, id: @user_set.id.to_s, set: {approved: true}
      end

      it "returns a 406 error when the set is invalid" do
        @user_set.stub(:update_attributes_and_embedded) { false }
        @user_set.stub(:errors).and_return({name: ["can't be blank"]})
        post :update, id: @user_set.id.to_s, set: {name: nil}
        response.code.should eq("422")
        response.body.should eq({errors: {name: ["can't be blank"]}}.to_json)
      end

      it "rescues from a :records format error and renders the error" do
        @user_set.stub(:update_attributes_and_embedded).and_raise(UserSet::WrongRecordsFormat)
        post :update, id: @user_set.id.to_s, set: {name: nil}
        response.code.should eq("422")
        response.body.should eq({errors: {records: ["The records array is not in a valid format."]}}.to_json)
      end
    end

    describe "DELETE 'destroy'" do
      before(:each) do
        @user_set = FactoryGirl.create(:user_set, user_id: @user.id)
        controller.current_user.user_sets.stub(:custom_find) { @user_set }
      end

      it "returns a 404 error when the set is not found" do
        controller.current_user.user_sets.stub(:custom_find) { nil }
        delete :destroy, id: @user_set.id.to_s
        response.code.should eq("404")
        response.body.should eq({errors: "Set with id: #{@user_set.id.to_s} was not found."}.to_json)
      end

      it "finds the @user_set through the user" do
        controller.current_user.user_sets.should_receive(:custom_find).with(@user_set.id.to_s) { @user_set }
        delete :destroy, id: @user_set.id.to_s
      end

      it "deletes the user set" do
        @user_set.should_receive(:destroy)
        delete :destroy, id: @user_set.id.to_s 
      end
    end 
  
  end

end
