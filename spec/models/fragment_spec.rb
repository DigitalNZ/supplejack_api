# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe Fragment do
  
    let!(:fragment) { Fragment.new }
  
    context 'default scope' do
      let!(:record) { FactoryGirl.build(:record_with_fragment) }

      before do 
        record.save
      end
       
      it 'should order the fragments from lower to higher priority' do
        fragment3 = record.fragments.create(priority: 3)
        fragment1 = record.fragments.create(priority: 1)
        fragment_1 = record.fragments.create(priority: -1)
        record.reload
        record.fragments.map(&:priority).should eq [-1, 0, 1, 3]
      end
    end
  
    describe 'build_mongoid_schema' do

      before do       
        Fragment.stub(:schema_class) { 'RecordSchema'.constantize }

        RecordSchema.stub(:fields) do
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
  
      it 'defines a string field' do
        Fragment.should_receive(:field).with(:title, type: String)
      end
  
      it 'defines a integer field' do
        Fragment.should_receive(:field).with(:count, type: Integer)
      end
  
      it 'defines a datetime field' do
        Fragment.should_receive(:field).with(:date, type: DateTime)
      end
  
      it 'defines a boolean field' do
        Fragment.should_receive(:field).with(:is_active, type: Boolean)
      end
  
      it 'defines a multivalue field' do
        Fragment.should_receive(:field).with(:subject, type: Array)
      end
  
      it 'does not define a field with stored false' do
        Fragment.should_not_receive(:field).with(:sort_date, anything)
      end

    end
  
    describe '.mutable_fields' do  

      {priority: Integer, job_id: String}.each do |name, type|
        it 'should return a hash that includes the key #{name} and value #{type}' do
          Fragment.mutable_fields[name.to_s].should eq type
        end
      end
  
      it 'should not include the source_id' do
        Fragment.mutable_fields.should_not have_key('source_id')
      end
  
      it 'should memoize the mutable_fields' do
        Fragment.class_variable_set('@@mutable_fields', nil)
        Fragment.should_receive(:fields).once.and_return({})
        Fragment.mutable_fields
        Fragment.mutable_fields
        Fragment.class_variable_set('@@mutable_fields', nil)
      end

    end
  
    describe '#primary?' do
      
      it 'returns true when priority is 0' do
        fragment.priority = 0
        fragment.primary?.should be_true
      end
  
      it 'returns false when priority is 1' do
        fragment.priority = 1
        fragment.primary?.should be_false
      end

    end
  
    describe '#clear_attributes' do

      it 'clears the mutable fields' do
        fragment.priority = 2
        fragment.job_id = 1234
        fragment.clear_attributes
        
        fragment.class.mutable_fields.each do |field, value|
          expect(fragment.send(field)).to be_nil
        end
      end

    end

    describe "#update_from_harvest" do
      
      it "handles nil values" do
        fragment.update_from_harvest(nil)
      end

      it "ignores invalid fields" do
        fragment.update_from_harvest({invalid_field: 'http://yahoo.com'})
        expect(fragment['invalid_field']).to be_nil
      end
      
      it "updates the updated_at even if the attributes didn't change'" do
        new_time = Time.now + 1.day
        Timecop.freeze(new_time) do
          fragment.update_from_harvest({})
          fragment.updated_at.to_i.should eq(new_time.to_i)
        end
      end

      it "uses the attribute setters for strings" do
        fragment.should_receive('job_id=').with('abc')
        fragment.update_from_harvest({:job_id => 'abc'})
      end

      it "stores the first element in the array for non array fields" do
        fragment.update_from_harvest({job_id: ['John Smith', 'Jim Bob']})
        expect(fragment.job_id).to eq 'John Smith'
      end

      it "should set the source_id" do
        fragment.update_from_harvest({source_id: ['census']})
        expect(fragment.source_id).to eq 'census'
      end

    end
  end
end

