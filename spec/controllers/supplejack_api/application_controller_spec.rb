# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe ApplicationController do
    routes { SupplejackApi::Engine.routes }
  
    # before(:each) do
    #   @controller = ApplicationController.new
    #   @controller.stub(:render) { nil }
    # end

    describe '#authenticate_user!' do
      pending 'Implement Rspec tests'
      # before(:each) do
      #   @controller.stub(:params) { {api_key: '12345'} }
      #   @controller.stub(:request) { double(:request, ip: '1.1.1.1', :format => :json)}
      #   @user = FactoryGirl.create(:user)
      #   @user.stub(:update_daily_activity) { nil }
      #   @controller.stub(:current_user) { @user }
      end
    end
end
