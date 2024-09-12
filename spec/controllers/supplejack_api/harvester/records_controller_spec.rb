# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Harvester::RecordsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:record) { build(:record) }

    context 'with a api_key with harvester role' do
      let(:harvester) { create(:harvest_user) }

      describe 'POST create' do
        before { allow(Record).to receive(:find_or_initialize_by_identifier) { record } }

        context 'preview is false' do
          it 'finds or initializes a record by identifier' do
            post :create, params: { record: { internal_identifier: '1234' }, api_key: harvester.api_key }

            expect(assigns(:record)).to be_a(SupplejackApi::Record)
          end
        end

        context 'preview is true' do
          it 'finds or initializes a preview record by identifier' do
            post :create, params: { record: { internal_identifier: '1234' }, preview: true, api_key: harvester.api_key }

            expect(assigns(:record)).to be_a(SupplejackApi::PreviewRecord)
          end
        end

        it 'sets the status based on the required fragments' do
          post :create, params: {
            record: { internal_identifier: '1234' },
            required_fragments: ['ndha_rights'],
            api_key: harvester.api_key
          }

          expect(assigns(:record).status).to eq 'partial'
        end

        it 'saves the record' do
          expect do
            post :create, params: { record: { internal_identifier: '1234' }, api_key: harvester.api_key }
          end.to change { Record.count }.by(1)
        end

        it 'returns status success and record_id if no exception is raised' do
          post :create, params: { record: { internal_identifier: '1234' }, api_key: harvester.api_key }

          data = JSON.parse(response.body)

          expect(data['status']).to eq 'success'
          expect(data['record_id']).to_not be(nil)
        end
      end

      describe 'POST create_batch' do
        it 'creates multiple records at a time' do
          expect do
            post :create_batch, params: {
              records: [
                {
                  fields: { internal_identifier: '1234' }
                },
                {
                  fields: { internal_identifier: '5678' },
                  required_fragments: []
                },
                {
                  fields: { internal_identifier: '9101112' },
                  required_fragments: []
                }
              ],
              api_key: harvester.api_key
            }
          end.to change { Record.count }.by(3)
        end

        it 'creates partial records when the records have required_fragments' do
          post :create_batch, params: {
            records: [
              {
                fields: { internal_identifier: '1234' },
                required_fragments: ['ndha_rights']
              },
              {
                fields: { internal_identifier: '5678' },
                required_fragments: []
              },
              {
                fields: { internal_identifier: '9101112' },
                required_fragments: []
              }
            ],
            api_key: harvester.api_key
          }

          expect(SupplejackApi::Record.first.status).to eq 'partial'
        end

        it 'returns information about the records that have been saved' do
          post :create_batch, params: {
            records: [
              {
                fields: { internal_identifier: '1234' }
              },
              {
                fields: { internal_identifier: '5678' },
                required_fragments: []
              },
              {
                fields: { internal_identifier: '9101112' },
                required_fragments: []
              }
            ],
            api_key: harvester.api_key
          }

          data = JSON.parse(response.body)

          expect(response).to be_successful

          data.each do |record|
            expect(record['status']).to eq 'success'
            expect(record['record_id']).to_not be(nil)
          end
        end

        it 'returns error information if a record has failed to be saved' do
          allow_any_instance_of(SupplejackApi::Record).to receive(:save).and_raise(StandardError)

          post :create_batch, params: {
            records: [
              {
                fields: { internal_identifier: '1234' }
              },
              {
                fields: { internal_identifier: '5678' },
                required_fragments: []
              },
              {
                fields: { internal_identifier: '9101112' },
                required_fragments: []
              }
            ],
            api_key: harvester.api_key
          }

          data = JSON.parse(response.body)

          expect(response).to be_successful

          data.each do |record|
            expect(record['status']).to eq 'failed'
            expect(record['exception_class']).to eq 'StandardError'
            expect(record['exception_class']).to eq 'StandardError'
            expect(record['backtrace']).not_to be(nil)
          end
        end
      end

      describe 'PUT delete' do
        it 'should find the record by internal_identifier' do
          expect(Record).to receive(:where).with({ internal_identifier: 'abc123' }) { [record] }
          put :delete, params: { id: 'abc123', api_key: harvester.api_key }
          expect(assigns(:record)).to eq record
        end

        it 'should update the records status attribute to deleted' do
          allow(Record).to receive(:where) { [record] }
          expect(record).to receive(:update_attribute).with(:status, 'deleted')
          put :delete, params: { id: 'abc123', api_key: harvester.api_key }
        end

        it 'handles a nil record' do
          allow(Record).to receive(:where) { [] }
          expect { put :delete, params: { id: 'abc123', api_key: harvester.api_key } }.to_not raise_exception
        end

        it 'returns status success if no exception is raised' do
          allow(Record).to receive(:where) { [record] }
          put :delete, params: { id: 'abc123', api_key: harvester.api_key }

          data = JSON.parse(response.body)
          expect(data['status']).to eq 'success'
          expect(data['record_id']).to eq 'abc123'
        end

        it 'returns status failed and backtrace metadata when an exception is raised' do
          allow(Record).to receive(:where).and_raise(StandardError.new('bang'))
          put :delete, params: { id: 'abc123', api_key: harvester.api_key }

          data = JSON.parse(response.body)
          expect(data['status']).to eq 'failed'
          expect(data['exception_class']).to eq 'StandardError'
          expect(data['message']).to eq 'bang'
          expect(data['backtrace']).not_to be_empty
          expect(data['record_id']).to eq 'abc123'
        end
      end

      describe 'DELETE flush' do
        before do
          allow(Record).to receive(:flush_old_records)
          expect(FlushOldRecordsWorker).to receive(:perform_async).with('source_id', 'abc123')
        end

        it 'calls flush_old_records' do
          delete :flush, params: { source_id: 'source_id', job_id: 'abc123', api_key: harvester.api_key }
        end

        it 'returns a 204' do
          delete :flush, params: { source_id: 'source_id', job_id: 'abc123', api_key: harvester.api_key }

          expect(response.code).to eq '204'
        end
      end

      describe 'GET #show' do
        it 'should find the record by internal_identifier' do
          expect(Record).to receive(:where).with({ record_id: 'abc123' }) { [record] }
          get :show, params: { id: 'abc123', api_key: harvester.api_key }
        end

        it 'should assign the record to @record' do
          allow(Record).to receive(:where) { [record] }
          get :show, params: { id: 'abc123', api_key: harvester.api_key }
          expect(assigns(:record)).to eq record
        end

        it 'should handle a nil record' do
          allow(Record).to receive(:where) { [] }
          expect { get :show, params: { id: 'abc123', api_key: harvester.api_key } }.to_not raise_exception
        end
      end

      describe 'PUT update' do
        let(:record) { double(:record).as_null_object }

        before do
          allow(controller).to receive(:authenticate_user!) { true }
          allow(Record).to receive(:custom_find) { record }
        end

        it 'finds the record and asigns it' do
          expect(Record).to receive(:custom_find).with('123', nil, { status: :all }) { record }
          put :update, params: { id: 123, record: { status: 'suppressed' }, api_key: harvester.api_key }, format: :json
          expect(assigns(:record)).to eq(record)
        end

        it 'updates the status of the record and marks it for indexing' do
          expect(record).to receive(:update).with(status: 'suppressed')
          put :update, params: { id: 123, record: { status: 'suppressed' }, api_key: harvester.api_key }, format: :json
        end
      end

      describe 'GET index' do
        let!(:records) { create_list(:record_with_fragment, 25) }
        let(:where_params) { ActionController::Parameters.new('fragments.job_id': records.first.job_id).permit! }
        let(:order_by) { double(:order_by) }

        it 'returns object with records based on search params' do
          expect(SupplejackApi::Record).to receive(:order_by).and_return(order_by)
          expect(order_by).to receive(:where).with(where_params).and_return(SupplejackApi::Record)

          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }
        end

        it 'requires at least one of the allowed search params' do
          get :index, params: {
            search: { 'fragments.hello': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }

          expect(response.status).to be 400
        end

        it 'returns records 20 per page' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }

          expect(JSON.parse(response.body)['records'].count).to eq 20
        end

        it 'returns the first record in the first page' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }

          expect(JSON.parse(response.body)['records'].map { |r| r['id'] }).to include records.first.id
        end

        it 'does not return the first record in the second page' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 2 },
            api_key: harvester.api_key
          }

          expect(JSON.parse(response.body)['records'].map { |r| r['id'] }).not_to include records.first.id
        end

        it 'responds with a json object of record ids and the fragments fragments' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }

          res = JSON.parse(response.body)

          expect(res.keys).to include 'records'
          expect(res.keys).to include 'meta'

          expect(res['meta']['page']).to be 1
          expect(res['meta']['total_pages']).to be 2
        end

        it 'adds mongo index hints to the query' do
          indexes = [{
            'v' => 1,
            'key' => { 'fragments.source_id' => 1 },
            'name' => 'fragments.source_id_1',
            'ns' => 'dnz_api_development.records'
          }]

          expect(SupplejackApi::Record).to receive_message_chain(:collection, :indexes, :as_json)
            .and_return(indexes)

          expect_any_instance_of(Mongoid::Criteria).to receive(:hint).with({ 'fragments.source_id' => 1 })

          get :index, params: {
            search: { 'fragments.source_id': records.first.source_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }
        end

        it 'order results by created_at ascending' do
          expect(SupplejackApi::Record).to receive(:order_by).with(%i[created_at asc]).and_call_original

          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }
        end

        it 'returns all fields when the fields parameter is missing' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key
          }

          body = JSON.parse(response.body)
          record = body['records'][0]

          RecordSchema.fields.each_key do |name|
            expect(record.key?(name.to_s)).to eq true
          end
        end

        it 'returns fields that have been asked for' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key,
            fields: ['id']
          }

          body = JSON.parse(response.body)

          expect(body['records'][0].key?('internal_identifier')).to eq false
        end

        it 'returns the all of the record includes by default' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key,
            fields: ['id'],
            record_includes: []
          }

          body = JSON.parse(response.body)

          body['records'].each do |record|
            expect(record.key?('fragments')).to eq true
          end
        end

        it 'only returns requested includes when provided' do
          get :index, params: {
            search: { 'fragments.job_id': records.first.job_id },
            search_options: { page: 1 },
            api_key: harvester.api_key,
            fields: ['id'],
            record_includes: ['nothing']
          }

          body = JSON.parse(response.body)

          body['records'].each do |record|
            expect(record.key?('fragments')).to eq false
          end
        end
      end
    end

    context 'with api_key without harvester role' do
      let(:user) { create(:user) }

      describe 'PUT update' do
        it 'returns unauthorized' do
          put :update, params: { id: 'abc123', record: { status: 'suppressed' }, api_key: user.api_key }, format: :json

          expect(response).to be_unauthorized
        end
      end

      describe 'GET #show' do
        it 'returns unauthorized' do
          get :show, params: { id: 'abc123', api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end

      describe 'DELETE flush' do
        it 'returns unauthorized' do
          put :flush, params: { id: 'abc123', api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end

      describe 'PUT delete' do
        it 'returns unauthorized' do
          put :delete, params: { id: 'abc123', api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end

      describe 'POST create' do
        it 'returns unauthorized' do
          post :create, params: { record: { internal_identifier: '1234' }, api_key: user.api_key }

          expect(response).to be_unauthorized
        end
      end
    end
  end
end
