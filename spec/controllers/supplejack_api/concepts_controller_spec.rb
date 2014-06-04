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
    end

    describe 'GET index' do
      before {
        @search = ConceptSearch.new
        @search.stub(:valid?) { true }
        @search.stub(:new) { @search }
      }

      it 'initializes a new search instance' do
        ConceptSearch.should_receive(:new).with(hash_including(text: 'dogs')).and_return(@search)
        get :index, api_key: 'apikey', text: 'dogs'
        assigns(:search).should eq(@search)
      end

      it 'sets the request url on search object' do
        controller.request.stub(:original_url).and_return('http://foo.com/blah')
        get :index, api_key: 'apikey'
        expect(assigns(:search).request_url).to eq 'http://foo.com/blah'
      end

      it 'should set the current_user on the search' do
        get :index, api_key: 'apikey'
        expect(assigns(:search).scope).to eq @user
      end

      it 'renders a the solr error when the query is invalid' do
        ConceptSearchSerializer.stub(:new).and_raise(RSolr::Error::Http.new({}, {}))
        controller.stub(:solr_error_message).and_return('Error')
        get :index, api_key: 'apikey', format: 'json'
        expect(response.body).to eq({errors: 'Error'}.to_json)
      end

      it 'renders a error when the requested field doesn\'t exist' do
        ConceptSearchSerializer.stub(:new).and_raise(Sunspot::UnrecognizedFieldError.new('No field configured for Concept with name "something"'))
        get :index, api_key: 'apikey', format: 'json', and: { something: true }
        expect(response.body).to eq({ errors: 'No field configured for Concept with name "something"' }.to_json)
      end

      it 'should return an error if the search request is invalid' do
        ConceptSearch.any_instance.stub(:valid?) { false }
        ConceptSearch.any_instance.stub(:errors) { ['The page parameter can not exceed 100,000'] }
        get :index, api_key: 'apikey', page: 100001, format: 'json'
        expect(response.body).to eq({ errors: ['The page parameter can not exceed 100,000'] }.to_json)
      end
    end

  end
end
