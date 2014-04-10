require "spec_helper"

module SupplejackApi
  require "spec_helper"
  
  describe Fragment do
  
    let!(:record) { FactoryGirl.build(:record, record_id: 1234) }
    let!(:fragment) { record.fragments.build(priority: 0, dnz_type: 'Book') }
  
    before { record.save }
  
    context "default scope" do
      it "should order the fragments from lower to higher priority" do
        fragment3 = record.fragments.create(priority: 3)
        fragment1 = record.fragments.create(priority: 1)
        fragment_1 = record.fragments.create(priority: -1)
        record.reload
        record.fragments.map(&:priority).should eq [-1, 0, 1, 3]
      end
    end
  
    describe "build_mongoid_schema" do
      before do
        Schema.stub(:fields) do
          {
            title: double(:field, name: :title, type: :string).as_null_object,
            count: double(:field, name: :count, type: :integer).as_null_object,
            date: double(:field, name: :date, type: :datetime).as_null_object,
            is_active: double(:field, name: :is_active, type: :boolean).as_null_object,
            subject: double(:field, name: :subject, type: :string, multi_value: true).as_null_object,
            sort_date: double(:field, name: :sort_date, type: :string, store: false).as_null_object,
          }
        end
        Fragment.stub(:field)
      end
  
      after do
        Fragment.build_mongoid_schema
      end
  
      it "defines a string field" do
        Fragment.should_receive(:field).with(:title, type: String)
      end
  
      it "defines a integer field" do
        Fragment.should_receive(:field).with(:count, type: Integer)
      end
  
      it "defines a datetime field" do
        Fragment.should_receive(:field).with(:date, type: DateTime)
      end
  
      it "defines a boolean field" do
        Fragment.should_receive(:field).with(:is_active, type: Boolean)
      end
  
      it "defines a multivalue field" do
        Fragment.should_receive(:field).with(:subject, type: Array)
      end
  
      it "does not define a field with stored false" do
        Fragment.should_not_receive(:field).with(:sort_date, anything)
      end
    end
  
    describe ".mutable_fields" do    
      {name: String, email: Array, nz_citizen: Boolean}.each do |name, type|
        it "should return a hash that includes the key #{name} and value #{type}" do
          Fragment.mutable_fields[name.to_s].should eq type
        end
      end
  
      it "should not include the source_id" do
        Fragment.mutable_fields.should_not have_key("source_id")
      end
  
      it "should memoize the mutable_fields" do
        Fragment.class_variable_set("@@mutable_fields", nil)
        Fragment.should_receive(:fields).once.and_return({})
        Fragment.mutable_fields
        Fragment.mutable_fields
        Fragment.class_variable_set("@@mutable_fields", nil)
      end
    end
  
    describe "#primary?" do
      it "returns true when priority is 0" do
        fragment.priority = 0
        fragment.primary?.should be_true
      end
  
      it "returns false when priority is 1" do
        fragment.priority = 1
        fragment.primary?.should be_false
      end
    end
  
    describe "#clear_attributes" do
      let(:record) { FactoryGirl.create(:record) }
      let!(:fragment) { record.fragments.create(nz_citizen: true) }
  
      it "clears the existing nz_citizen" do
        fragment.clear_attributes
        fragment.nz_citizen.should be_nil
      end
    end
  end
end
