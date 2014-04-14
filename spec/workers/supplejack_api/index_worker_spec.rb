require "spec_helper"

module SupplejackApi
  describe IndexWorker do
  
    describe "#find_all" do
      let(:record1) { FactoryGirl.create(:record, record_id: 12345) }
      let(:record2) { FactoryGirl.create(:record, record_id: 67890) }
  
      it "finds all records by id" do
        IndexWorker.find_all("Record", [record1.id, record2.id]).should eq [record1, record2]
      end
  
      it "returns records even when some where not found" do
        IndexWorker.find_all("Record", ["504d333aa9b6ad1860000056", record1.id]).should eq [record1]
      end
  
      it "handles individual records" do
        IndexWorker.find_all("Record", record1.id).should eq [record1]
      end
    end
  
    describe "perform" do
      let(:record) { double(:record).as_null_object }
  
      it "indexes all given record id's" do
        IndexWorker.should_receive(:find_all).with("Record", ["123"]) { [record] }
        IndexWorker.should_receive(:index).with([record])
        IndexWorker.perform(:index, {class: "Record", id: ["123"]})
      end
  
      it "removes all given record id's" do
        IndexWorker.should_receive(:find_all).with("Record", ["123"]) { [record] }
        IndexWorker.should_receive(:remove).with([record])
        IndexWorker.perform(:remove, {class: "Record", id: ["123"]})
      end
  
      it "rescues from a RSolr::Error::Http errors when commiting SOLR" do
        Sunspot.stub(:commit).and_raise(RSolr::Error::Http.new({}, {}))
        IndexWorker.perform(:commit)
      end
    end
  end

end
