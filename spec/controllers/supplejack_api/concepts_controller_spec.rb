# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
        expect(Concept).to receive(:custom_find).with('123', @user, {}).and_return(@concept)
        get :show, id: 123, search: {}, api_key: 'abc123', format: "json"
        expect(assigns(:concept)).to eq(@concept)
      end

      it 'renders a error when records is not found' do
        allow(Concept).to receive(:custom_find).and_raise(Mongoid::Errors::DocumentNotFound.new(Concept, ['123'], ['123']))
        get :show, id: 123, search: {}, api_key: 'abc123', :format => 'json'
        expect(response.body).to eq({:errors => 'Concept with ID 123 was not found'}.to_json)
      end
    end

    # describe 'GET index' do
    #   before {
    #     @search = ConceptSearch.new
    #     allow(@search).to receive(:valid?) { false }
    #     allow(@search).to receive(:new) { @search }
    #   }

    #   it 'initializes a new search instance' do
    #     expect(ConceptSearch).to receive(:new).with(hash_including(text: 'dogs')).and_return(@search)
    #     get :index, api_key: 'apikey', text: 'dogs'
    #     expect(assigns(:search)).to eq(@search)
    #   end

    #   it 'sets the request url on search object' do
    #     allow_any_instance_of(ConceptSearch).to receive(:valid?) { false }
    #     allow(controller.request).to receive(:original_url).and_return('http://foo.com/blah')
    #     get :index, api_key: 'apikey', format: "json"
    #     expect(assigns(:search).request_url).to eq 'http://foo.com/blah'
    #   end

    #   it 'should set the current_user on the search' do
    #     allow_any_instance_of(ConceptSearch).to receive(:valid?) { false }
    #     get :index, api_key: 'apikey', format: "json"
    #     expect(assigns(:search).scope).to eq @user
    #   end

    #   it 'renders a the solr error when the query is invalid' do
    #     allow(ConceptSearchSerializer).to receive(:new).and_raise(RSolr::Error::Http.new({}, {}))
    #     allow(controller).to receive(:solr_error_message).and_return('Error')
    #     get :index, api_key: 'apikey', format: 'json'
    #     expect(response.body).to eq({errors: 'Error'}.to_json)
    #   end

    #   it 'renders a error when the requested field doesn\'t exist' do
    #     allow(ConceptSearchSerializer).to receive(:new).and_raise(Sunspot::UnrecognizedFieldError.new('No field configured for Concept with name "something"'))
    #     get :index, api_key: 'apikey', format: 'json', and: { something: true }
    #     expect(response.body).to eq({ errors: 'No field configured for Concept with name "something"' }.to_json)
    #   end

    #   it 'should return an error if the search request is invalid' do
    #     allow_any_instance_of(ConceptSearch).to receive(:valid?) { false }
    #     allow_any_instance_of(ConceptSearch).to receive(:errors) { ['The page parameter can not exceed 100,000'] }
    #     get :index, api_key: 'apikey', page: 100001, format: 'json'
    #     expect(response.body).to eq({ errors: ['The page parameter can not exceed 100,000'] }.to_json)
    #   end
    # end

  end
end
