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
      
      it 'renders a error when the requested field doesn\'t exist' do
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
  end

end
