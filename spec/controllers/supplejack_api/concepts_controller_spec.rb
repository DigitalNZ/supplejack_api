

require 'spec_helper'

module SupplejackApi
  describe ConceptsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    before { @user = FactoryBot.create(:user, authentication_token: 'apikey', role: 'developer') }

    describe 'GET show' do
      before {
        @concept = FactoryBot.create(:concept)
        allow(controller).to receive(:current_user) { @user }
      }

      it 'should find the concept and assign it' do
        expect(Concept).to receive(:custom_find).with('123', @user, nil).and_return(@concept)
        get :show, params: { id: 123, search: {}, api_key: 'abc123' }, format: "json"
        expect(assigns(:concept)).to eq(@concept)
      end

      it 'renders a error when records is not found' do
        allow(Concept).to receive(:custom_find).and_raise(Mongoid::Errors::DocumentNotFound.new(Concept, ['123'], ['123']))
        get :show, params: { id: 123, search: {}, api_key: 'abc123' }, :format => 'json'
        expect(response.body).to eq({:errors => 'Concept with ID 123 was not found'}.to_json)
      end
    end

    describe 'GET index' do
      before {
        @search = ConceptSearch.new
        allow(@search).to receive(:valid?) { false }
        allow(@search).to receive(:new) { @search }
      }

      it 'initializes a new search instance' do
        expect(ConceptSearch).to receive(:new).with(hash_including(text: 'dogs')).and_return(@search)
        get :index, params: { api_key: 'apikey', text: 'dogs' }
        expect(assigns(:search)).to eq(@search)
      end

      it 'sets the request url on search object' do
        allow_any_instance_of(ConceptSearch).to receive(:valid?) { false }
        get :index, params: { api_key: 'apikey' }, format: "json"
        expect(assigns(:search).request_url).to eq 'http://test.host/concepts?api_key=apikey'
      end

      it 'should set the current_user on the search' do
        allow_any_instance_of(ConceptSearch).to receive(:valid?) { false }
        get :index, params: { api_key: 'apikey' }, format: "json"
        expect(assigns(:search).scope).to eq @user
      end

      it 'renders a the solr error when the query is invalid' do
        allow(SearchSerializer).to receive(:new).and_raise(RSolr::Error::Http.new({}, {}))
        get :index, params: { api_key: 'apikey' }, format: 'json'
        expect(response.body).to include 'RSolr::Error::Http'
      end

      it 'renders a error when the requested field doesn\'t exist' do
        allow(SearchSerializer).to receive(:new).and_raise(Sunspot::UnrecognizedFieldError.new('No field configured for Concept with name "something"'))
        get :index, params: { api_key: 'apikey', and: { something: true } }, format: 'json'
        expect(response.body).to eq({ errors: 'No field configured for Concept with name "something"' }.to_json)
      end

      it 'should return an error if the search request is invalid' do
        allow_any_instance_of(ConceptSearch).to receive(:valid?) { false }
        allow_any_instance_of(ConceptSearch).to receive(:errors) { ['The page parameter can not exceed 100,000'] }
        get :index, params: { api_key: 'apikey', page: 100001 }, format: 'json'
        expect(response.body).to eq({ errors: ['The page parameter can not exceed 100,000'] }.to_json)
      end
    end

  end
end
