require "spec_helper"

module SupplejackApi
  describe Harvester::RecordsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:record) { FactoryBot.build(:record) }

    context 'with a api_key with harvester role' do
      let(:api_key) { create(:user, role: 'harvester').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { harvester: double(:harvester, harvester: true) } }
      end

      describe "POST create" do
        before(:each) do
          allow(Record).to receive(:find_or_initialize_by_identifier) { record }
        end

        context "preview is false" do
          it "finds or initializes a record by identifier" do
            expect(Record).to receive(:find_or_initialize_by_identifier).with("internal_identifier" => "1234") { record }
            post :create, params: { record: {internal_identifier: "1234"}, api_key: api_key }
            expect(assigns(:record)).to eq record
          end
        end

        context "preview is true" do
          it "finds or initializes a preview record by identifier" do
            expect(PreviewRecord).to receive(:find_or_initialize_by_identifier).with("internal_identifier" => "1234") { record }
            post :create, params: { record: {internal_identifier: "1234"}, preview: true, api_key: api_key }
            expect(assigns(:record)).to eq record
          end
        end

        context "record has a priority other then 0" do
          it "creates or updates the fragment" do
            rec = {
              "internal_identifier" => "1234",
              "title" => "Hi",
              "priority" => "10"
            }
            expect(record).to receive(:create_or_update_fragment).with(rec)
            post :create, params: { record: rec, api_key: api_key }
          end
        end

        it "sets the status based on the required fragments" do
          expect(record).to receive(:set_status).with(['ndha_rights'])
          post :create, params: { record: {"internal_identifier" => "1234"}, required_fragments: ['ndha_rights'], api_key: api_key }
        end

        it "saves the record" do
          expect(record).to receive(:save)
          post :create, params: { record: {"internal_identifier" => "1234"}, api_key: api_key }
        end

        it "unsets null fields" do
          expect(record).to receive(:unset_null_fields)
          post :create, params: { record: {"internal_identifier" => "1234"}, api_key: api_key }
        end

        it 'returns status success and record_id if no exception is raised' do
          allow(Record).to receive(:find_or_initialize_by_identifier) { record }

          post :create, params: { record: { 'internal_identifier' => '1234' }, api_key: api_key }

          data = JSON.parse(response.body)

          expect(data['status']).to eq 'success'
          expect(data['record_id']).to eq record.record_id
        end

        it 'returns status failed and backtrace metadata when an exception is raised' do
          allow(Record).to receive(:find_or_initialize_by_identifier) { record }
          allow(record).to receive(:save!).and_raise(StandardError.new('bang'))

          post :create, params: { record: { 'internal_identifier' => '1234' }, api_key: api_key }

          data = JSON.parse(response.body)

          expect(data['status']).to eq 'failed'
          expect(data['exception_class']).to eq 'StandardError'
          expect(data['message']).to eq 'bang'
          expect(data['raw_data']).not_to be_empty
          expect(data['backtrace']).not_to be_empty
          expect(data['record_id']).to eq record.record_id
        end
      end

      describe "PUT delete" do
        it "should find the record by internal_identifier" do
          expect(Record).to receive(:where).with({internal_identifier: "abc123"}) { [record] }
          put :delete, params: { id: "abc123", api_key: api_key}
          expect(assigns(:record)).to eq record
        end

        it "should update the records status attribute to deleted" do
          allow(Record).to receive(:where) { [record] }
          expect(record).to receive(:update_attribute).with(:status, "deleted")
          put :delete, params: { id: "abc123", api_key: api_key}
        end

        it "handles a nil record" do
          allow(Record).to receive(:where) { [] }
          expect { put :delete, params: { id: "abc123", api_key: api_key }}.to_not raise_exception
        end

        it 'returns status success if no exception is raised' do
          allow(Record).to receive(:where) { [record] }
          put :delete, params: { id: 'abc123', api_key: api_key}

          data = JSON.parse(response.body)
          expect(data['status']).to eq 'success'
          expect(data['record_id']).to eq 'abc123'
        end

        it 'returns status failed and backtrace metadata when an exception is raised' do
          allow(Record).to receive(:where).and_raise(StandardError.new('bang'))
          put :delete, params: { id: 'abc123', api_key: api_key}

          data = JSON.parse(response.body)
          expect(data['status']).to eq 'failed'
          expect(data['exception_class']).to eq 'StandardError'
          expect(data['message']).to eq 'bang'
          expect(data['backtrace']).not_to be_empty
          expect(data['record_id']).to eq 'abc123'
        end
      end

      describe "DELETE flush" do
        before do
          allow(Record).to receive(:flush_old_records)
          expect(FlushOldRecordsWorker).to receive(:perform_async).with('source_id', 'abc123')
        end

        it "calls flush_old_records" do
          delete :flush, params: {source_id: 'source_id', job_id: 'abc123', api_key: api_key}
        end

        it "returns a 204" do
          delete :flush, params: {source_id: 'source_id', job_id: 'abc123', api_key: api_key}

          expect(response.code).to eq '204'
        end
      end

      describe 'GET #show' do
        it 'should find the record by internal_identifier' do
          expect(Record).to receive(:where).with({ record_id: 'abc123' }) { [record] }
          get :show, params: { id: 'abc123', api_key: api_key }
        end

        it 'should assign the record to @record' do
          allow(Record).to receive(:where) { [record] }
          get :show, params: { id: 'abc123', api_key: api_key }
          expect(assigns(:record)).to eq record
        end

        it 'should handle a nil record' do
          allow(Record).to receive(:where) { [] }
          expect { get :show, params: { id: 'abc123', api_key: api_key }}.to_not raise_exception
        end
      end

      describe "PUT update" do
        let(:record) { double(:record).as_null_object }

        before do
          allow(controller).to receive(:authenticate_user!) { true }
          allow(Record).to receive(:custom_find) { record }
        end

        it 'finds the record and asigns it' do
          expect(Record).to receive(:custom_find).with('123', nil, {status: :all}) { record }
          put :update, params: { id: 123, record: { status: 'supressed' }, api_key: api_key}, format: :json
          expect(assigns(:record)).to eq(record)
        end

        it "updates the status of the record" do
          expect(record).to receive(:update_attribute).with(:status, 'supressed')
          put :update, params: { id: 123, record: { status: 'supressed' }, api_key: api_key}, format: :json
        end
      end

      describe 'GET index' do
        let!(:records) { FactoryBot.create_list(:record_with_fragment, 25) }
        let(:where_params) { ActionController::Parameters.new('fragments.job_id': records.first.job_id).permit! }

        it 'returns object with records based on search params' do
          expect(Record).to receive(:where).with(where_params).and_call_original
          get :index, params: { search: { 'fragments.job_id': records.first.job_id }, search_options: { page: 1 }, api_key: api_key }
        end

        it 'requires at least one of the allowed search params' do
          get :index, params: { search: { 'fragments.hello': records.first.job_id }, search_options: { page: 1 }, api_key: api_key }
          expect(response.status).to be 400
        end

        it 'returns records 20 per page' do
          get :index, params: { search: { 'fragments.job_id': records.first.job_id }, search_options: { page: 1 }, api_key: api_key }
          expect(JSON.parse(response.body)['records'].count).to eq 20
        end

        it 'returns the first record in the first page' do
          get :index, params: { search: { 'fragments.job_id': records.first.job_id }, search_options: { page: 1 }, api_key: api_key }
          expect(JSON.parse(response.body)['records'].map { |r| r['id'] }).to include records.first.id
        end

        it 'does not return the first record in the second page' do
          get :index, params: { search: { 'fragments.job_id': records.first.job_id }, search_options: { page: 2 }, api_key: api_key }
          expect(JSON.parse(response.body)['records'].map { |r| r['id'] }).not_to include records.first.id
        end

        it 'responds with a json object of record ids and the fragments fragments' do
          get :index, params: { search: { 'fragments.job_id': records.first.job_id }, search_options: { page: 1 }, api_key: api_key }
          res = JSON.parse(response.body)

          expect(res.keys).to include 'records'
          expect(res.keys).to include 'meta'

          expect(res['meta']['page']).to be 1
          expect(res['meta']['total_pages']).to be 2
        end

        it 'adds mongo index hints to the query' do
          indexes = [{"v"=>1, "key"=>{"fragments.source_id"=>1}, "name"=>"fragments.source_id_1", "ns"=>"dnz_api_development.records"}]
          SupplejackApi.config.record_class.stub_chain(:collection, :indexes, :as_json).and_return indexes
          expect_any_instance_of(Mongoid::Criteria).to receive(:hint).with({"fragments.source_id"=>1})

          get :index, params: { search: { 'fragments.source_id': records.first.source_id }, search_options: { page: 1 }, api_key: api_key }
        end
      end
    end

    context 'with api_key without harvester role' do
      let(:api_key) { create(:user, role: 'admin').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { harvester: double(:harvester, harvester: nil) } }
      end

      describe "PUT update" do
        it 'returns forbidden' do
          put :update, params: { id: 'abc123', record: { status: 'supressed' }, api_key: api_key}, format: :json
        end
      end

      describe 'GET #show' do
        it 'returns forbidden' do
          get :show, params: { id: 'abc123', api_key: api_key }
        end
      end

      describe "DELETE flush" do
        it 'returns forbidden' do
          put :flush, params: { id: "abc123", api_key: api_key}
        end
      end

      describe "PUT delete" do
        it 'returns forbidden' do
          put :delete, params: { id: "abc123", api_key: api_key}
        end
      end

      describe "POST create" do
        it 'returns forbidden' do
          post :create, params: { record: {internal_identifier: "1234"}, api_key: api_key }
        end
      end
    end
  end
end
