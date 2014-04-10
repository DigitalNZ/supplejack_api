require 'spec_helper'

module SupplejackApi
  describe Record do
    let(:record) { FactoryGirl.build(:record, record_id: 1234) }
  
    describe "#custom_find" do
      before(:each) do
        @record = FactoryGirl.create(:record, record_id: 54321)
        @record.stub(:find_next_and_previous_records).and_return(nil)
      end
  
      it "should search for a record via its record_id" do
        Record.custom_find(54321).should eq(@record)
      end
  
      it "should search for a record via its ObjectId (MongoDB autoassigned id)" do
        Record.custom_find(@record.id).should eq(@record)
      end
  
      it "should raise a error when a record is not found" do
        expect { Record.custom_find(111) }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
  
      it "shouldn't call find when the mongo id is invalid'" do
        Record.should_not_receive(:find)
        expect { Record.custom_find("1234567abc") }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
  
      it "should find next and previous records" do
        @user = double(:user)
        Record.stub_chain(:unscoped, :active, :where, :first).and_return(@record)
        @record.should_receive(:find_next_and_previous_records).with(@user, {text: "dogs"})
        Record.custom_find(54321, @user, {text: "dogs"})
      end
  
      [Sunspot::UnrecognizedFieldError, Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error_klass|
        it "should rescue from a #{error_klass}" do
          Record.stub_chain(:unscoped, :active, :where, :first).and_return(@record)
          @record.stub(:find_next_and_previous_records).and_raise(error_klass)
          Record.custom_find(54321, nil, {text: "dogs"})
        end
      end
  
      it "should rescue from a RSolr::Error::Http" do
        Record.stub_chain(:unscoped, :active, :where, :first).and_return(@record)
        @record.stub(:find_next_and_previous_records).and_raise(RSolr::Error::Http.new({}, {}))
        Record.custom_find(54321, nil, {text: "dogs"})
      end
  
      context "restricting inactive records" do
        it "finds only active records" do
          @record.update_attribute(:status, "deleted")
          @record.reload
          expect { Record.custom_find(54321) }.to raise_error(Mongoid::Errors::DocumentNotFound)
        end
  
        it "finds also inactive records when :status => :all" do
          @record.update_attribute(:status, "deleted")
          @record.reload
          Record.custom_find(54321, nil, {status: :all}).should eq @record
        end
  
        it "doesn't find next and previous record without any search options'" do
          Record.stub_chain(:unscoped, :where, :first) { @record }
          @record.should_not_receive(:find_next_and_previous_records)
          Record.custom_find(54321, nil, {status: :all})
        end
  
        it "doesn't break with nil options'" do
          Record.custom_find(54321, nil, nil).should eq @record
        end
      end
    end
  
    describe "#find_multiple" do
      before(:each) do
        @record = FactoryGirl.create(:record, record_id: 54321)
      end
  
      it "should find multiple records by numeric id" do
        r1 = FactoryGirl.create(:record, record_id: 999)
        r2 = FactoryGirl.create(:record, record_id: 998)
        Record.find_multiple([999, 998]).should include(r1, r2)
        Record.find_multiple([999, 998]).should have(2).items
      end
  
      it "should find multiple records by ObjectId" do
        r1 = FactoryGirl.create(:record)
        r2 = FactoryGirl.create(:record)
        Record.find_multiple([r1.id, r2.id]).should include(r1, r2)
        Record.find_multiple([r1.id, r2.id]).should have(2).items
      end
  
      it "should find multiple records with ObjectId's and numeric id's" do
        r1 = FactoryGirl.create(:record, record_id: 997)
        r2 = FactoryGirl.create(:record)
        Record.find_multiple([997, r2.id]).should include(r1, r2)
        Record.find_multiple([997, r2.id]).should have(2).items
      end
  
      it "returns an empty array when ids is nil" do
        Record.find_multiple(nil).should eq []
      end
  
      it "should not return inactive records" do
        r1 = FactoryGirl.create(:record, record_id: 997, status: "deleted")
        r2 = FactoryGirl.create(:record, record_id: 667, status: "active")
        records = Record.find_multiple([997, 667]).to_a
        records.should_not include(r1)
        records.should include(r2)
      end
  
      it "returns the records in the same order as requested" do
        r1 = FactoryGirl.create(:record, record_id: 1, created_at: Time.now-10.days)
        r2 = FactoryGirl.create(:record, record_id: 2, created_at: Time.now)
        records = Record.find_multiple([2,1]).to_a
        records.first.should eq r2
      end
    end
  
    describe "#source_url" do
      it "should return the API url for the record" do
        record.source_url.should eq("#{ENV['HTTP_HOST']}/records/1234/source")
      end
    end
  
    describe "#find_next_and_previous_records" do
      pending 'Implement record search'
      # before(:each) do
      #   @record = FactoryGirl.create(:record, :record_id => 123)
      #   @search = Search.new
      #   @search.stub(:total).and_return(3)
      #   Search.stub(:new).and_return(@search)
      #   @user = FactoryGirl.build(:user)
      # end
  
      # it "should not do anything when options are empty" do
      #   Search.should_not_receive(:new)
      #   record.find_next_and_previous_records(@user, {})
      # end
  
      # it "should not do anything when options is null" do
      #   Search.should_not_receive(:new)
      #   record.find_next_and_previous_records(@user, nil)
      # end
  
      # it "should not do anything when the solr request fails" do
      #   @search.stub(:valid?) { false }
      #   @search.should_not_receive(:hits)
      #   record.find_next_and_previous_records(@user, {text: "dogs"})
      # end
  
      # it "should set the scope in the search" do
      #   Search.stub(:new) { @search }
      #   @search.should_receive("scope=").with(@user)
      #   record.find_next_and_previous_records(@user, {text: "dogs"})
      # end
  
      # context "records within the current page" do
      #   before do
      #     Record.stub(:find).with("12345") {mock_model(Record, :record_id => 654)}
      #     Record.stub(:find).with("98765") {mock_model(Record, :record_id => 987)}
      #   end
  
      #   it "should set the previous record" do
      #     @search.stub(:hits) { mock_hits(["12345", @record.id, "98765"]) }
      #     Record.should_receive(:find).with("12345").and_return(mock_model(Record, :record_id => 654))
      #     @record.find_next_and_previous_records(@user, text: "dogs")
      #     @record.previous_record.should eq(654)
      #   end
  
      #   it "should set the next record" do
      #     @search.stub(:hits).and_return(mock_hits([nil, @record.id, "98765"]))
      #     Record.should_receive(:find).with("98765").and_return(mock_model(Record, :record_id => 987))
      #     @record.find_next_and_previous_records(@user, {text: "dogs"})
      #     @record.next_record.should eq(987)
      #   end
      # end
  
      # context "first record in the results" do
      #   before(:each) do
      #     @search.stub(:hits).and_return(mock_hits([@record.id, "12345", "98765"]))
      #   end
  
      #   it "should perform a new search for the previous page" do
      #     @search.stub(:page).and_return(2)
      #     Search.should_receive(:new).with(anything)
      #     Search.should_receive(:new).with(hash_including(page: 1))
      #     @record.find_next_and_previous_records(@user, {text: "dogs"})
      #     @record.previous_page.should eq(1)
      #   end
  
      #   it "should not perform a new search when in the first page" do
      #     @search.stub(:hits).and_return(mock_hits([@record.id, "12345", "98765"]))
      #     Search.should_receive(:new).once
      #     @record.find_next_and_previous_records(@user, {text: "dogs"})
      #     @record.previous_record.should be_nil
      #   end
      # end
  
      # context "last record in the results" do
      #   before(:each) do
      #     @search.stub(:hits).and_return(mock_hits(["12345", "98765", @record.id]))
      #     @search.stub(:per_page).and_return(3)
      #   end
  
      #   it "should perform a new search for the next page" do
      #     @search.stub(:total).and_return(6)
      #     Search.should_receive(:new).with(anything)
      #     Search.should_receive(:new).with(hash_including(page: 2))
      #     @record.find_next_and_previous_records(@user, {text: "dogs"})
      #     @record.next_page.should eq(2)
      #   end
  
      #   it "should not perform a new search when in the last page" do
      #     @search.stub(:total).and_return(3)
      #     Search.should_receive(:new).once
      #     @record.find_next_and_previous_records(@user, {text: "dogs"})
      #     @record.next_record.should be_nil
      #   end
      # end
    end
  
    def mock_hits(primary_keys=[])
      primary_keys.map {|pk| double(:hit, primary_key: pk.to_s )}
    end
  
    # describe "harvest_job_id=()" do
    #   it "finds a harvest job and assigns it to harvest_job" do
    #     harvest_job = FactoryGirl.create(:harvest_job, harvest_job_id: 13)
    #     record = Record.new(harvest_job_id: 13)
    #     record.harvest_job.should eq(harvest_job)
    #   end
  
    #   it "returns nil for a non existent harvest job" do
    #     record = Record.new(harvest_job_id: 13)
    #     record.harvest_job.should be_nil
    #   end
    # end
  
    describe "#active?" do
      before(:each) do
        @record = FactoryGirl.build(:record)
      end
  
      it "returns true when state is active" do
        @record.status = "active"
        @record.active?.should be_true
      end
  
      it "returns false when state is deleted" do
        @record.status = "deleted"
        @record.active?.should be_false
      end
    end
  
    describe "#should_index?" do
      before(:each) do
        @record = FactoryGirl.build(:record)
      end
  
      it "returns false when active? is false" do
        @record.stub(:active?) { false }
        @record.should_index?.should be_false
      end
  
      it "returns true when active? is true" do
        @record.stub(:active?) { true }
        @record.should_index?.should be_true
      end
    end
  
  end
end
