# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  module Support
    describe Harvestable do
      let(:record) { FactoryGirl.build(:record) }

      describe '#create_or_update_fragment' do
        before { record.save }

        context 'existing fragment' do
          before do
            @fragment = record.fragments.create(source_id: 'nz_census', name: 'John Smith', age: 50) 
            record.create_or_update_fragment({'source_id' => 'nz_census', 'age' => 100})
          end

          it 'updates the fragment attributes' do
            expect(@fragment.age).to eq 100
          end

          it 'nilifies the fields not updated in the fragment' do
            expect(@fragment.name).to be_nil
          end
        end

        context 'new fragment' do
          it 'creates a new fragment' do
            record.create_or_update_fragment({'source_id' => 'nz_census', 'name' => 'John Smith', 'priority' => [1]})
            fragment = record.find_fragment('nz_census')
            expect(fragment).to_not be_nil
            expect(fragment.name).to eq 'John Smith'
            expect(fragment.priority).to eq 1
          end
        end
      end

      describe '#set_status' do
        before {
          record.fragments.build(source_id: 'nz_census', name: 'John Smith')
        }

        it 'sets the status to active if nil is passed' do
          record.set_status(nil)
          expect(record.status).to eq 'active'
        end

        it 'sets the status to active if an empty array is passed' do
          record.set_status([])
          expect(record.status).to eq 'active'
        end

        it 'sets the status to partial if one required fragment does not exists' do
          record.set_status(['nz_census', 'thumbnails'])
          expect(record.status).to eq 'partial'
        end

        it 'sets the status to active if all required fragments exist' do
          record.fragments.build(source_id: 'thumbnails', name: 'John Smith')
          record.set_status(['nz_census', 'thumbnails'])
          expect(record.status).to eq 'active'
        end
      end

      describe '#clear_attributes' do
        let(:record) { FactoryGirl.create(:record, internal_identifier: "1234") }

        it 'doesn\'t clear the _id attribute' do
          record.clear_attributes
          expect(record._id).to_not be_nil
        end
  
      end

      describe '#unset_null_fields' do
        it 'unsets null fields Mongo' do
          record = FactoryGirl.create(:record, name: 'John Smith')
          record.update_attributes(name: nil)
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record).to_not have_key('name')
        end

        it 'should unset null fields inside fragments' do
          record = FactoryGirl.build(:record_with_fragment, record_id: 1234)
          record.primary_fragment.update_attributes(address: nil)
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record['fragments'][0]).to_not have_key('address')
        end

        it 'should handle null fragments' do
          record = FactoryGirl.create(:record_with_fragment, record_id: 1234)
          allow(record).to receive(:raw_attributes) { {'fragments' => [nil]} }
          expect { record.unset_null_fields }.to_not raise_exception
        end

        it 'should handle false fields inside fragments' do
          record = FactoryGirl.create(:record_with_fragment, record_id: 1234)
          record.primary_fragment.update_attributes(nz_citizen: false)
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record['fragments'][0]).to have_key('nz_citizen')
        end

        it 'doesn\'t unset any field with values' do
          record = FactoryGirl.create(:record_with_fragment, record_id: 1234)
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record).to include({'record_id' => 1234})
          expect(raw_record['fragments'][0]).to include({'address' => 'Wellington'})
        end

        it 'should not trigger a db query if there is nothing to unset' do
          record = FactoryGirl.create(:record)
          expect(record.collection).to_not receive(:find)
          record.unset_null_fields
        end

        it 'should handle new records' do
          records = Record.new
          record.unset_null_fields
        end
      end

      describe '.find_or_initialize_by_identifier' do
        it 'finds from the internal_identifier param' do
          expect(Record).to receive(:find_or_initialize_by).with(internal_identifier: '1234')
          Record.find_or_initialize_by_identifier({internal_identifier: '1234'})
        end

        it 'handles an array of identifiers' do
          expect(Record).to receive(:find_or_initialize_by).with(internal_identifier: '1234')
          Record.find_or_initialize_by_identifier({internal_identifier: ['1234']})
        end
      end

      describe '.flush_old_records' do
        before do
          @record1 = FactoryGirl.create(:record_with_fragment)
          @record1.primary_fragment.job_id = '123'
          @record1.save

          @record2 = FactoryGirl.create(:record_with_fragment)
          @record2.primary_fragment.job_id = 'abc'
          @record2.save
        end

        it 'sets status deleted on records with the source_id, but without the given job_id' do
          Record.flush_old_records @record1.primary_fragment.source_id, '123'

          expect(@record1.reload.status).to eq 'active'
          expect(@record2.reload.status).to eq 'deleted'
        end

        it 'only deletes record that don\'t have the job_id in any fragment' do
          @record1.fragments.create(priority: -4, job_id: 'abc', source_id: 'a-fragment')
          Record.flush_old_records @record1.primary_fragment.source_id, '123'

          expect(@record1.reload.status).to eq 'active'
          expect(@record2.reload.status).to eq 'deleted'
        end

        it 'indexs deleted records' do
          expect(Sunspot).to receive(:remove)
          Record.flush_old_records @record1.primary_fragment.source_id, '123'
        end
      end
    end
  end
end