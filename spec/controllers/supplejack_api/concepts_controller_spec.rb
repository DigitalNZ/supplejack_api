# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe ConceptsController do
    routes { SupplejackApi::Engine.routes }
    
    before { @user = FactoryGirl.create(:user, authentication_token: 'apikey', role: 'developer') }
  
    describe 'GET show' do
      before {
        @concept = double(:concept)
        controller.stub(:current_user) { @user }
      }
      
      it 'should find the concept and assign it' do
        Concept.should_receive(:custom_find).with('123', @user, {}).and_return(@concept)
        get :show, id: 123, search: {}, api_key: 'abc123'
        assigns(:concept).should eq(@concept)
      end
      
      it 'renders a error when records is not found' do
        Concept.stub(:custom_find).and_raise(Mongoid::Errors::DocumentNotFound.new(Concept, ['123'], ['123']))
        get :show, id: 123, search: {}, api_key: 'abc123', :format => 'json'
        response.body.should eq({:errors => 'Concept with ID 123 was not found'}.to_json)
      end
      
      # it 'merges the scope in the options' do
      #   Record.should_receive(:custom_find).with('123', @user, {'and' => {'category' => 'Books'}}).and_return(@record)
      #   get :show, id: 123, search: {and: {category: 'Books'}}, api_key: 'abc123'
      #   assigns(:record).should eq(@record)
      # end
    end

  end
end
