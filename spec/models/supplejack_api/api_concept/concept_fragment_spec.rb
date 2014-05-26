# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  module ApiConcept
    describe ConceptFragment do
  
      let!(:concept) { FactoryGirl.build(:concept, concept_id: 1234) }
      let!(:fragment) { concept.fragments.build(priority: 0, dnz_type: 'Book') }
    
      before { concept.save }
    
      context 'default scope' do
        it 'should order the fragments from lower to higher priority' do
          fragment3 = concept.fragments.create(priority: 3)
          fragment1 = concept.fragments.create(priority: 1)
          fragment_1 = concept.fragments.create(priority: -1)
          concept.reload
          concept.fragments.map(&:priority).should eq [-1, 0, 1, 3]
        end
      end
    
      describe 'build_mongoid_schema' do
        before do
          ConceptSchema.stub(:fields) do
            {
              title: double(:field, name: :title, type: :string).as_null_object,
              count: double(:field, name: :count, type: :integer).as_null_object,
              date: double(:field, name: :date, type: :datetime).as_null_object,
              is_active: double(:field, name: :is_active, type: :boolean).as_null_object,
              subject: double(:field, name: :subject, type: :string, multi_value: true).as_null_object,
              sort_date: double(:field, name: :sort_date, type: :string, store: false).as_null_object,
            }
          end
          ConceptFragment.stub(:field)
        end
    
        after do
          ConceptFragment.build_mongoid_schema
        end
    
        it 'defines a string field' do
          ConceptFragment.should_receive(:field).with(:title, type: String)
        end
    
        it 'defines a integer field' do
          ConceptFragment.should_receive(:field).with(:count, type: Integer)
        end
    
        it 'defines a datetime field' do
          ConceptFragment.should_receive(:field).with(:date, type: DateTime)
        end
    
        it 'defines a boolean field' do
          ConceptFragment.should_receive(:field).with(:is_active, type: Boolean)
        end
    
        it 'defines a multivalue field' do
          ConceptFragment.should_receive(:field).with(:subject, type: Array)
        end
    
        it 'does not define a field with stored false' do
          ConceptFragment.should_not_receive(:field).with(:sort_date, anything)
        end
      end
    
      describe '.mutable_fields' do    
        {name: String, email: Array, nz_citizen: Boolean}.each do |name, type|
          it 'should return a hash that includes the key #{name} and value #{type}' do
            ConceptFragment.mutable_fields[name.to_s].should eq type
          end
        end
    
        it 'should not include the source_id' do
          ConceptFragment.mutable_fields.should_not have_key('source_id')
        end
    
        it 'should memoize the mutable_fields' do
          ConceptFragment.class_variable_set('@@mutable_fields', nil)
          ConceptFragment.should_receive(:fields).once.and_return({})
          ConceptFragment.mutable_fields
          ConceptFragment.mutable_fields
          ConceptFragment.class_variable_set('@@mutable_fields', nil)
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
        let(:record) { FactoryGirl.create(:record) }
        let!(:fragment) { record.fragments.create(nz_citizen: true) }
    
        it 'clears the existing nz_citizen' do
          fragment.clear_attributes
          fragment.nz_citizen.should be_nil
        end
      end

      describe "#update_from_harvest" do
        it "updates the name with the value" do
          fragment.update_from_harvest({name: 'John Smith'})
          fragment.name.should eq 'John Smith'
        end

        it "handles nil values" do
          fragment.update_from_harvest(nil)
        end

        it "ignores invalid fields" do
          fragment.update_from_harvest({invalid_field: 'http://yahoo.com'})
          fragment['invalid_field'].should be_nil
        end

        it "stores uniq values for each field" do
          fragment.update_from_harvest({children: ['Jim', 'Bob', 'Jim']})
          fragment.children.should eq ['Jim', 'Bob']
        end
        
        it "updates the updated_at even if the attributes didn't change'" do
          new_time = Time.now + 1.day
          Timecop.freeze(new_time) do
            fragment.update_from_harvest({})
            fragment.updated_at.to_i.should eq(new_time.to_i)
          end
        end

        it "uses the attribute setters for strings" do
          fragment.should_receive('name=').with('John Smith')
          fragment.update_from_harvest({:name => 'John Smith'})
        end

        it "uses the attribute setters for Arrays" do
          fragment.should_receive('children=').with(['Jim', 'Bob'])
          fragment.update_from_harvest({:children => ['Jim', 'Bob']})
        end

        it "stores the first element in the array for non array fields" do
          fragment.update_from_harvest({name: ['John Smith', 'Jim Bob']})
          fragment.name.should eq 'John Smith'
        end

        it "should set the source_id" do
          fragment.update_from_harvest({source_id: ['census']})
          fragment.source_id.should eq 'census'
        end
      end

    end
  end
end
