require 'spec_helper'

module SupplejackApi
  describe ApplicationController do
    routes { SupplejackApi::Engine.routes }
  
    # before(:each) do
    #   @controller = ApplicationController.new
    #   @controller.stub(:render) { nil }
    # end

    # describe '#authenticate_user!' do
    #   before(:each) do
    #     @controller.stub(:params) { {api_key: '12345'} }
    #     @controller.stub(:request) { double(:request, ip: '1.1.1.1', :format => :json)}
    #     @user = FactoryGirl.create(:user)
    #     @user.stub(:update_daily_activity) { nil }
    #     @controller.stub(:current_user) { @user }
    #   end
    # end
end
