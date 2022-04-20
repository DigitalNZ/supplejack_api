# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe RecordsController, type: :controller do
    routes { SupplejackApi::Engine.routes }
    let!(:record) { create(:record) }
    let!(:user)   { create(:user) }

    before { @user = create(:user, authentication_token: 'apikey', role: 'developer') }

    describe 'GET index' do
      before do
        @search = RecordSearch.new
        allow(@search).to receive(:valid?) { true }
        allow(RecordSearch).to receive(:new) { @search }
      end

      it 'should initialize a new search instance' do
        allow_any_instance_of(RecordSearch).to receive(:valid?) { false }
        allow_any_instance_of(RecordSearch).to receive(:errors) { [] }

        expect(RecordSearch).to receive(:new).with(hash_including(text: 'dogs')).and_return(@search)
        get :index, params: { api_key: 'apikey', text: 'dogs' }, format: :json

        expect(assigns(:search)).to eq(@search)
      end

      it 'should set the request url on search object' do
        allow_any_instance_of(RecordSearch).to receive(:valid?) { false }
        allow_any_instance_of(RecordSearch).to receive(:errors) { [] }

        get :index, params: { api_key: 'apikey', text: '123' }, format: :json

        expect(assigns[:search].request_url).to eq 'http://test.host/records?api_key=apikey&text=123'
      end

      it 'should set the current_user on the search' do
        allow_any_instance_of(RecordSearch).to receive(:valid?) { false }
        allow_any_instance_of(RecordSearch).to receive(:errors) { [] }

        expect(@search).to receive(:scope=).with(@user)
        get :index, params: { api_key: 'apikey' }, format: :json
      end

      it 'should return an error if the search request is invalid' do
        allow(@search).to receive(:valid?) { false }
        allow(@search).to receive(:errors) { ['The page parameter can not exceed 100,000'] }
        get :index, params: { api_key: 'apikey', page: 100_001 }, format: 'json'

        expect(response.body).to eq({ errors: ['The page parameter can not exceed 100,000'] }.to_json)

        expect(response).to be_a_bad_request
      end

      it 'should return timeout 408 error if error is solr unavailable' do
        allow_any_instance_of(RecordSearch).to receive(:valid?).and_raise(Timeout::Error)

        get :index, params: { api_key: 'apikey', text: 'dogs' }, format: :json

        expect(response.body).to eq({ errors: ['Request timed out'] }.to_json)

        expect(response).to have_http_status(:request_timeout)
      end

      it 'should return timeout 400 error if error error' do
        allow_any_instance_of(RecordSearch).to receive(:valid?) { false }
        allow_any_instance_of(RecordSearch).to receive(:errors) { [RSolr::Error::Http] }

        get :index, params: { api_key: 'apikey', text: 'dogs' }, format: :json

        expect(response).to be_a_bad_request
      end

      context 'json' do
        before do
          get :index, params: { api_key: user.authentication_token }, format: :json
        end

        it 'has a succesful response code' do
          expect(response).to be_successful
        end

        it 'sets the correct Content-Type' do
          expect(response.header['Content-Type']).to eq 'application/json; charset=utf-8'
        end
      end

      context 'jsonp' do
        before do
          get :index,
              params: { api_key: user.authentication_token, jsonp: 'jQuery18306022017613970934_1505872751581' },
              format: :json
        end

        it 'has a succesful response code' do
          expect(response).to be_successful
        end

        it 'sets the correct Content-Type' do
          expect(response.header['Content-Type']).to eq 'text/javascript; charset=utf-8'
        end
      end

      context 'xml' do
        before do
          get :index, params: { api_key: user.authentication_token }, format: :xml
        end

        it 'has a succesful response code' do
          expect(response).to be_successful
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
        allow(RecordSchema).to receive(:roles) { { developer: developer_restriction } }
      end

      it 'should find the record and assign it' do
        expect(Record).to receive(:custom_find).with('123', @user, nil).and_return(@record)
        get :show, params: { id: 123, search: {}, api_key: 'apikey' }, format: 'json'
        expect(assigns(:record)).to eq(@record)
      end

      it 'renders a error when records is not found' do
        allow(Record).to receive(:custom_find).and_raise(
          Mongoid::Errors::DocumentNotFound.new(Record, ['123'], ['123'])
        )

        get :show, params: { id: 123, search: {}, api_key: 'apikey' }, format: 'json'

        expect(response.body).to eq({ errors: 'Record with ID 123 was not found' }.to_json)
      end

      it 'merges the scope in the options' do
        expect(Record).to receive(:custom_find).with('123', @user, { 'and' => { 'category' => 'Books' } })
                                               .and_return(@record)

        get :show, params: { id: 123, search: { and: { category: 'Books' } }, api_key: 'apikey' }, format: 'json'
      end

      context 'json' do
        before do
          get :show, params: { id: record.id, api_key: user.authentication_token }, format: :json
        end

        it 'has a succesful response code' do
          expect(response).to be_successful
        end

        it 'sets the correct Content-Type' do
          expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
        end
      end

      context 'jsonp' do
        before do
          get :show,
              params: { id: record.id,
                        api_key: user.authentication_token,
                        jsonp: 'jQuery18306022017613970934_1505872751581' },
              format: :json
        end

        it 'has a succesful response code' do
          expect(response).to be_successful
        end

        it 'sets the correct Content-Type' do
          expect(response.headers['Content-Type']).to eq 'text/javascript; charset=utf-8'
        end
      end

      context 'xml' do
        before do
          get :show, params: { id: record.id, api_key: user.authentication_token }, format: :xml
        end

        it 'has a succesful response code' do
          expect(response).to be_successful
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
        allow(RecordSchema).to receive(:roles) { { developer: developer_restriction } }
      end

      it 'should find multiple records and assign them' do
        @records = [create(:record), create(:record)]
        allow(Record).to receive(:find_multiple) { @records }
        get :multiple, params: { record_ids: [123, 124, 456], api_key: 'apikey' }, format: 'json'
        expect(assigns(:records)).to eq(@records)
      end
    end

    describe 'GET more_like_this' do
      before(:each) do
        @record = create(:record)
        allow(controller).to receive(:current_user) { @user }
        allow(RecordSchema).to receive(:roles) { { developer: developer_restriction } }
        allow(Record).to receive(:custom_find).with(@record.id).and_return(@record)
        allow(@record).to receive(:more_like_this).and_return(double(:mlt, results: [@record]))
      end

      context 'json' do
        before do
          get :more_like_this,
              params: { record_id: @record.id, api_key: @user.authentication_token },
              format: :json
        end

        it 'has a succesful response code' do
          expect(response).to be_successful
        end

        it 'sets the correct Content-Type' do
          expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
        end

        it 'returns records that are more like this' do
          result = JSON.parse(response.body)

          expect(result['records'].count).to eq 1
        end
      end
    end

    describe '#default_serializer_options' do
      it 'should return a hash with info for serialization' do
        @search = RecordSearch.new
        allow(RecordSearch).to receive(:new) { @search }

        controller.default_serializer_options
        expect(assigns(:search)).to eq(@search)
      end

      it 'should merge in the search fields' do
        @search = RecordSearch.new(fields: 'title,description,verbose')
        allow(RecordSearch).to receive(:new) { @search }

        expect(controller.default_serializer_options).to eq(fields: %i[title description], groups: %i[verbose])
      end
    end

    describe '#set_concept_param' do
      it 'adds concept_id in the parameter' do
        controller.params = { concept_id: 3 }
        controller.send(:set_concept_param)

        expect(controller.params[:and].to_unsafe_h).to eq('concept_id' => 3)
      end

      it 'merges concept_id with existing "and" parameter' do
        controller.params = { concept_id: 3, and: { category: 'Category A' } }
        controller.send(:set_concept_param)

        expect(controller.params[:and].to_unsafe_h).to eq('concept_id' => 3, 'category' => 'Category A')
      end
    end
  end
end
