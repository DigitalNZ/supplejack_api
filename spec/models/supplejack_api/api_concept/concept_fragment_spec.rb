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
      let!(:fragment) { concept.fragments.build(priority: 0) }
      let(:fragment_class) { ConceptFragment }

      before { concept.save }

      it { should have_index_for(status: 1) }
      it { should have_index_for(internal_identifier: 1) }
      it { should have_index_for(updated_at: 1) }

      describe 'schema_class' do
        it 'should return ConceptSchema' do
          expect(ConceptFragment.schema_class).to eq ConceptSchema
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
          fragment_class.stub(:field)

          ConceptSchema.stub(:mongo_indexes) do
            {
              count_date: double(:mongo_index, name: :count_date, fields: [{ count: 1, date: 1 }], index_options: {background: true}).as_null_object
            }
          end
          fragment_class.stub(:mongo_indexes)
        end

        after do
          fragment_class.build_mongoid_schema
        end

        context 'creating fields' do
          it 'defines a string field' do
            fragment_class.should_receive(:field).with(:title, type: String)
          end

          it 'defines a integer field' do
            fragment_class.should_receive(:field).with(:count, type: Integer)
          end

          it 'defines a datetime field' do
            fragment_class.should_receive(:field).with(:date, type: DateTime)
          end

          it 'defines a boolean field' do
            fragment_class.should_receive(:field).with(:is_active, type: Boolean)
          end

          it 'defines a multivalue field' do
            fragment_class.should_receive(:field).with(:subject, type: Array)
          end

          it 'does not define a field with stored false' do
            fragment_class.should_not_receive(:field).with(:sort_date, anything)
          end
        end

        context 'creating indexes' do
          it 'should create a single field index' do
            fragment_class.should_receive(:index).with({:count=>1, :date=>1}, {:background=>true})
          end
        end
      end

      describe '.mutable_fields' do
        {description: String, sameAs: Array, dateOfDeath: DateTime}.each do |name, type|
          it 'should return a hash that includes the key #{name} and value #{type}' do
            fragment_class.mutable_fields[name.to_s].should eq type
          end
        end

        it 'should not include the source_id' do
          fragment_class.mutable_fields.should_not have_key('source_id')
        end

        it 'should memoize the mutable_fields' do
          fragment_class.class_variable_set('@@mutable_fields', nil)
          fragment_class.should_receive(:fields).once.and_return({})
          fragment_class.mutable_fields
          fragment_class.mutable_fields
          fragment_class.class_variable_set('@@mutable_fields', nil)
        end
      end

      context 'default scope' do
        it 'should order the fragments from lower to higher priority' do
          fragment3 = concept.fragments.create(priority: 3)
          fragment1 = concept.fragments.create(priority: 1)
          fragment_1 = concept.fragments.create(priority: -1)
          concept.reload
          concept.fragments.map(&:priority).should eq [-1, 0, 1, 3]
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
        let(:concept) { FactoryGirl.create(:concept) }
        let(:fragment) { concept.fragments.create(gender: 'male') }

        it 'clears the existing gender' do
          fragment.clear_attributes
          fragment.gender.should be_nil
        end
      end

      describe '#update_from_harvest' do
        it 'updates the label with the value' do
          fragment.update_from_harvest({label: 'John Smith'})
          fragment.label.should eq 'John Smith'
        end

        it 'handles nil values' do
          fragment.update_from_harvest(nil)
        end

        it 'ignores invalid fields' do
          fragment.update_from_harvest({invalid_field: 'http://yahoo.com'})
          fragment['invalid_field'].should be_nil
        end

        it 'stores uniq values for each field' do
          fragment.update_from_harvest({isRelatedTo: ['Jim', 'Bob', 'Jim']})
          fragment.isRelatedTo.should eq ['Jim', 'Bob']
        end

        it 'updates the updated_at even if the attributes didn\'t change' do
          new_time = Time.now + 1.day
          Timecop.freeze(new_time) do
            fragment.update_from_harvest({})
            fragment.updated_at.to_i.should eq(new_time.to_i)
          end
        end

        it 'uses the attribute setters for strings' do
          fragment.should_receive('label=').with('John Smith')
          fragment.update_from_harvest({:label => 'John Smith'})
        end

        it 'uses the attribute setters for Arrays' do
          fragment.should_receive('isRelatedTo=').with(['Jim', 'Bob'])
          fragment.update_from_harvest({:isRelatedTo => ['Jim', 'Bob']})
        end

        it 'stores the first element in the array for non array fields' do
          fragment.update_from_harvest({label: ['John Smith', 'Jim Bob']})
          fragment.label.should eq 'John Smith'
        end

        it 'should set the source_id' do
          fragment.update_from_harvest({source_id: ['census']})
          fragment.source_id.should eq 'census'
        end
      end


    end
  end
end
