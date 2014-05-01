require "spec_helper"

module SupplejackApi
  describe Harvester::RecordsController do
    routes { SupplejackApi::Engine.routes }

    let(:record) { mock_model(Record).as_null_object }
    
    describe "POST create" do
      before(:each) do
        Record.stub(:find_or_initialize_by_identifier) { record }
      end

      context "preview is false" do
        it "finds or initializes a record by identifier" do
          Record.should_receive(:find_or_initialize_by_identifier).with("internal_identifier" => "1234") { record }
          post :create, record: {internal_identifier: "1234"}
          assigns(:record).should eq record
        end
      end
      
      context "preview is true" do
        it "finds or initializes a preview record by identifier" do
          PreviewRecord.should_receive(:find_or_initialize_by_identifier).with("internal_identifier" => "1234") { record }
          post :create, record: {internal_identifier: "1234"}, preview: true
          assigns(:record).should eq record
        end
      end

      context "record has a priority other then 0" do
        it "creates or updates the fragment" do
          rec = {
            "internal_identifier" => "1234", 
            "title" => "Hi",
            "priority" => "10"
          }
          record.should_receive(:create_or_update_fragment).with(rec)
          post :create, record: rec
        end
      end

      it "sets the status based on the required fragments" do
        record.should_receive(:set_status).with(['ndha_rights'])
        post :create, record: {"internal_identifier" => "1234"}, required_fragments: ['ndha_rights']
      end

      it "sets the landing_url" do
        record.should_receive('landing_url=').with('http://google.com/landing.html')
        post :create, record: {"internal_identifier" => "1234", landing_url: 'http://google.com/landing.html'}
      end

      it "saves the record" do
        record.should_receive(:save)
        post :create, record: {"internal_identifier" => "1234"}
      end

      it "unsets null fields" do
        record.should_receive(:unset_null_fields)
        post :create, record: {"internal_identifier" => "1234"}
      end
    end

    describe "PUT delete" do
      it "should find the record by internal_identifier" do
        Record.should_receive(:where).with({internal_identifier: "abc123"}) { [record] }
        put :delete, id: "abc123"
        assigns(:record).should eq record
      end

      it "should update the records status attribute to deleted" do
        Record.stub(:where) { [record] }
        record.should_receive(:update_attribute).with(:status, "deleted")
        put :delete, id: "abc123"
      end

      it "handles a nil record" do
        Record.stub(:where) { [] }
        expect { put :delete, id: "abc123" }.to_not raise_exception
      end
    end

    describe "DELETE flush" do
      before do
        Record.stub(:flush_old_records)
      end

      it "calls flush_old_records" do
        Resque.should_receive(:enqueue).with(FlushOldRecordsWorker, 'tapuhi', 'abc123')
        delete :flush, source_id: 'tapuhi', job_id: 'abc123'
      end

      it "returns a 204" do
        delete :flush, source_id: 'tapuhi', job_id: 'abc123'
        response.code.should eq '204'     
      end
    end

    describe 'GET #show' do
      it 'should find the record by internal_identifier' do
        Record.should_receive(:where).with({ record_id: 'abc123' }) { [record] }
        get :show, id: 'abc123'
      end

      it 'should assign the record to @record' do
        Record.stub(:where) { [record] }
        get :show, id: 'abc123'
        assigns(:record).should eq record
      end

      it 'should handle a nil record' do
        Record.stub(:where) { [] }
        expect { get :show, id: 'abc123' }.to_not raise_exception
      end
    end

    describe "PUT update" do
      let(:record) { double(:record).as_null_object }

      before do
        controller.stub(:authenticate_user!) { true }
        Record.stub(:custom_find) { record }
      end

      it 'finds the record and asigns it' do
        Record.should_receive(:custom_find).with('123', nil, {status: :all}) { record }
        put :update, id: 123, record: { status: 'supressed' }
        assigns(:record).should eq(record)
      end

      it "updates the status of the record" do
        record.should_receive(:update_attribute).with(:status, 'supressed')
        put :update, id: 123, record: { status: 'supressed' }
      end
    end
  end
end