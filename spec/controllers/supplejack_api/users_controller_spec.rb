# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UsersController do
    routes { SupplejackApi::Engine.routes }
    
    let(:user) { FactoryGirl.create(:user, authentication_token: "abc123", role: "admin") }
  
    describe 'GET show' do
      it 'should assign @user' do
        get :show, id: user.id, api_key: user.authentication_token
        assigns(:user).should eq(user)
      end
    end
    
    # describe "POST create" do
    #   it "should create a new user" do
    #     User.should_receive(:create).with({"name" => "Federico"}).and_return(user)
    #     post :create, api_key: user.authentication_token, user: {name: "Federico"}, format: "json"
    #   end
    # end
  
    # describe "PUT update" do
    #   before :each do
    #     User.stub(:custom_find) { user }
    #   end
  
    #   it "should find the user" do
    #     put :update, id: user.api_key, api_key: user.authentication_token
    #     assigns(:user).should eq user
    #   end
  
    #   it "updates the user attributes" do
    #     user.should_receive(:update_attributes).with({"username" => "john"})
    #     put :update, id: user.api_key, api_key: user.authentication_token, user: {username: "john"}
    #   end
    # end
  
    # describe "DELETE destroy" do
    #   it "should find the user" do
    #     delete :destroy, id: user.id, api_key: user.authentication_token
    #     assigns(:user).should eq user
    #   end
  
    #   it "destroys the user" do
    #     User.stub(:find) { user }
    #     user.should_receive(:destroy)
    #     delete :destroy, id: user.id, api_key: user.authentication_token
    #   end
    # end
  
  end

end
