# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RecordsController, type: :controller do
    routes { SupplejackApi::Engine.routes }
    let!(:record) { create(:record) }
    let!(:user)   { create(:user) }

    before {
      @user = FactoryGirl.create(:user, authentication_token: 'apikey', role: 'developer')
    }

    describe 'GET index' do
      before {
        @search = RecordSearch.new
        allow(@search).to receive(:valid?) { true }
        allow(RecordSearch).to receive(:new) {@search}
      }

      it 'should initialize a new search instance' do
        allow_any_instance_of(RecordSearch).to receive(:valid?) { false }
        expect(RecordSearch).to receive(:new).with(hash_including(text: 'dogs')).and_return(@search)
        get :index, api_key: 'apikey', text: "dogs", format: "json"
        expect(assigns(:search)).to eq(@search)
      end

      it 'should set the request url on search object' do
        allow_any_instance_of(RecordSearch).to receive(:valid?) { false }
        allow(controller.request).to receive(:original_url).and_return('http://foo.com/blah')
        expect(@search).to receive(:request_url=).with('http://foo.com/blah')
        get :index, api_key: 'apikey', format: "json"
      end

      it 'should set the current_user on the search' do
        allow_any_instance_of(RecordSearch).to receive(:valid?) { false }
        expect(@search).to receive(:scope=).with(@user)
        get :index, api_key: 'apikey', format: "json"
      end

      it 'renders a the solr error when the query is invalid' do
        allow(SearchSerializer).to receive(:new).and_raise(RSolr::Error::Http.new({}, {}))
        allow(controller).to receive(:solr_error_message).and_return('Error')
        get :index, api_key: 'apikey', format: 'json'
        expect(response.body).to eq({errors: 'Error'}.to_json)
      end

      it "renders a error when the requested field doesn't exist" do
        allow(SearchSerializer).to receive(:new).and_raise(Sunspot::UnrecognizedFieldError.new('No field configured for Record with name "something"'))
        get :index, api_key: 'apikey', format: 'json', and: {:something => true}
        expect(response.body).to eq({:errors => 'No field configured for Record with name "something"'}.to_json)
      end

      it 'should return an error if the search request is invalid' do
        allow(@search).to receive(:valid?) { false }
        allow(@search).to receive(:errors) { ['The page parameter can not exceed 100,000'] }
        get :index, api_key: 'apikey', page: 100001, format: 'json'
        expect(response.body).to eq({errors: ['The page parameter can not exceed 100,000']}.to_json)
      end

      context 'json' do
        before do
          get :index, api_key: user.authentication_token, format: :json
        end

        it 'has a succesful response code' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the correct Content-Type' do
          expect(response.header['Content-Type']).to eq "application/json; charset=utf-8"
        end
      end

      context 'jsonp' do
        before do
          get :index, api_key: user.authentication_token, format: :json, jsonp: 'jQuery18306022017613970934_1505872751581'
        end

        it 'has a succesful response code' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the correct Content-Type' do
          expect(response.header['Content-Type']).to eq 'text/javascript; charset=utf-8'
        end
      end

      context 'xml' do
        before do
          get :index, api_key: user.authentication_token, format: :xml
        end

        it 'has a succesful response code' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the correct Content-Type' do
          expect(response.header['Content-Type']).to eq 'application/xml; charset=utf-8'
        end
      end
    end

    describe 'GET show' do
      let(:developer_restriction) { double(:developer_restriction).as_null_object }

      before(:each) do
        @record = create(:record)
        allow(controller).to receive(:current_user) { @user }
        allow(RecordSchema).to receive(:roles) { {developer: developer_restriction} }
      end

      it 'should find the record and assign it' do
        expect(Record).to receive(:custom_find).with('123', @user, {}).and_return(@record)
        get :show, id: 123, search: {}, api_key: 'apikey', format: 'json'
        expect(assigns(:record)).to eq(@record)
      end

      it 'renders a error when records is not found' do
        allow(Record).to receive(:custom_find).and_raise(Mongoid::Errors::DocumentNotFound.new(Record, ['123'], ['123']))
        get :show, id: 123, search: {}, api_key: 'apikey', format: 'json'
        expect(response.body).to eq({:errors => 'Record with ID 123 was not found'}.to_json)
      end

      it 'merges the scope in the options' do
        expect(Record).to receive(:custom_find).with('123', @user, {'and' => {'category' => 'Books'}}).and_return(@record)
        get :show, id: 123, search: {and: {category: 'Books'}}, api_key: 'apikey', format: 'json'
        expect(assigns(:record)).to eq(@record)
      end

      context 'json' do
        before do
          get :show, id: record.id, api_key: user.authentication_token, format: :json
        end

        it 'has a succesful response code' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the correct Content-Type' do
          expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
        end
      end

      context 'jsonp' do
        before do
          get :show, id: record.id, api_key: user.authentication_token, format: :json, jsonp: 'jQuery18306022017613970934_1505872751581'
        end

        it 'has a succesful response code' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the correct Content-Type' do
          expect(response.headers['Content-Type']).to eq 'text/javascript; charset=utf-8'
        end
      end

      context 'xml' do
        before do
          get :show, id: record.id, api_key: user.authentication_token, format: :xml
        end

        it 'has a succesful response code' do
          expect(response).to have_http_status(:success)
        end

        it 'sets the correct type Content-Type' do
          expect(response.headers['Content-Type']).to eq 'application/xml; charset=utf-8'
        end
      end
    end

    describe 'GET multiple' do
      let(:developer_restriction) { double(:developer_restriction).as_null_object }

      before(:each) do
        @record = create(:record)
        allow(controller).to receive(:current_user) { @user }
        allow(RecordSchema).to receive(:roles) { {developer: developer_restriction} }
      end

      it 'should find multiple records and assign them' do
        @records = [create(:record), create(:record)]
        allow(Record).to receive(:find_multiple) { @records }
        get :multiple, record_ids: [123, 124, 456], api_key: 'apikey', format: 'json'
        expect(assigns(:records)).to eq(@records)
      end
    end

    describe '#default_serializer_options' do
      before(:each) do
        @search = RecordSearch.new
        allow(RecordSearch).to receive(:new) { @search }
      end

      it 'should return a hash with info for serialization' do
        controller.default_serializer_options
        expect(assigns(:search)).to eq(@search)
      end

      it 'should merge in the search fields' do
        allow(@search).to receive(:field_list).and_return([:title, :description])
        allow(@search).to receive(:group_list).and_return([:verbose])
        expect(controller.default_serializer_options).to eq({fields: [:title, :description], groups: [:verbose]})
      end
    end

    describe '#set_concept_param' do
      it 'adds concept_id in the parameter' do
        controller.params = { concept_id: 3 }
        controller.send(:set_concept_param)
        expect(controller.params[:and]).to eq({'concept_id' => 3})
      end

      it 'merges concept_id with existing "and" parameter' do
        controller.params = { concept_id: 3, and: { category: 'Category A' } }
        controller.send(:set_concept_param)
        expect(controller.params[:and]).to eq({'concept_id' => 3, 'category' => 'Category A'})
      end
    end
  end
end
