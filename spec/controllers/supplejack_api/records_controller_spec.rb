# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RecordsController do
    routes { SupplejackApi::Engine.routes }
    
    before(:each) do
      @user = FactoryGirl.create(:user, authentication_token: 'apikey', role: 'developer')
    end
  
    describe 'GET index' do
      before(:each) do
        @search = Search.new
        @search.stub(:valid?) { true }
        Search.stub(:new) {@search}
      end
      
      it 'should initialize a new search instance' do
        Search.should_receive(:new).with(hash_including(text: 'dogs')).and_return(@search)
        get :index, api_key: 'apikey', text: "dogs"
        assigns(:search).should eq(@search)
      end
      
      it 'should set the request url on search object' do
        controller.request.stub(:original_url).and_return('http://foo.com/blah')
        @search.should_receive(:request_url=).with('http://foo.com/blah')
        get :index, api_key: 'apikey'
      end
      
      it 'should set the current_user on the search' do
        @search.should_receive(:scope=).with(@user)
        get :index, api_key: 'apikey'
      end
      
      it 'renders a the solr error when the query is invalid' do
        SearchSerializer.stub(:new).and_raise(RSolr::Error::Http.new({}, {}))
        controller.stub(:solr_error_message).and_return('Error')
        get :index, api_key: 'apikey', format: 'json'
        response.body.should eq({errors: 'Error'}.to_json)
      end
      
      it "renders a error when the requested field doesn't exist" do
        SearchSerializer.stub(:new).and_raise(Sunspot::UnrecognizedFieldError.new('No field configured for Record with name "something"'))
        get :index, api_key: 'apikey', format: 'json', and: {:something => true}
        response.body.should eq({:errors => 'No field configured for Record with name "something"'}.to_json)
      end
  
      it 'should return an error if the search request is invalid' do
        @search.stub(:valid?) { false }
        @search.stub(:errors) { ['The page parameter can not exceed 100,000'] }
        get :index, api_key: 'apikey', page: 100001, format: 'json'
        response.body.should eq({errors: ['The page parameter can not exceed 100,000']}.to_json)
      end
    end

    describe 'GET show' do
      before(:each) do
        @record = double(:record)
        controller.stub(:current_user) { @user }
      end
      
      it 'should find the record and assign it' do
        Record.should_receive(:custom_find).with('123', @user, {}).and_return(@record)
        get :show, id: 123, search: {}, api_key: 'abc123'
        assigns(:record).should eq(@record)
      end
      
      it 'renders a error when records is not found' do
        Record.stub(:custom_find).and_raise(Mongoid::Errors::DocumentNotFound.new(Record, ['123'], ['123']))
        get :show, id: 123, search: {}, api_key: 'abc123', :format => 'json'
        response.body.should eq({:errors => 'Record with ID 123 was not found'}.to_json)
      end
      
      it 'merges the scope in the options' do
        Record.should_receive(:custom_find).with('123', @user, {'and' => {'category' => 'Books'}}).and_return(@record)
        get :show, id: 123, search: {and: {category: 'Books'}}, api_key: 'abc123'
        assigns(:record).should eq(@record)
      end
    end

     describe '#default_serializer_options' do
      before(:each) do
        @search = Search.new
        Search.stub(:new) { @search }
      end
      
      it 'should return a hash with info for serialization' do
        controller.default_serializer_options
        assigns(:search).should eq(@search)
      end
      
      it 'should merge in the search fields' do
        @search.stub(:field_list).and_return([:title, :description])
        @search.stub(:group_list).and_return([:verbose])
        controller.default_serializer_options.should eq({fields: [:title, :description], groups: [:verbose]})
      end
    end
  end

end
