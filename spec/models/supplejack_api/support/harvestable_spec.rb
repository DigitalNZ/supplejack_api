require 'spec_helper'

module SupplejackApi
  module Support
    describe Harvestable do
      let(:record) { FactoryBot.build(:record) }

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

      describe '#unset_null_fields' do
        it 'unsets null fields Mongo' do
          record = FactoryBot.create(:record, name: 'John Smith')
          record.update_attributes(name: nil)
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record).to_not have_key('name')
        end

        it 'should unset null fields inside fragments' do
          record = FactoryBot.build(:record_with_fragment)
          record.primary_fragment.update_attributes(address: nil)
          record.reload
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record['fragments'][0]).to_not have_key('address')
        end

        it 'should handle null fragments' do
          record = FactoryBot.create(:record_with_fragment, record_id: 1234)
          allow(record).to receive(:raw_attributes) { {'fragments' => [nil]} }
          expect { record.unset_null_fields }.to_not raise_exception
        end

        it 'should handle false fields inside fragments' do
          record = FactoryBot.create(:record_with_fragment, record_id: 1234)
          record.primary_fragment.update_attributes(nz_citizen: false)
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record['fragments'][0]).to have_key('nz_citizen')
        end

        it 'doesn\'t unset any field with values' do
          record = FactoryBot.create(:record_with_fragment)
          record.unset_null_fields
          raw_record = record.reload.raw_attributes
          expect(raw_record).to include({'record_id' => record.record_id})
          expect(raw_record['fragments'][0]).to include({'address' => 'Wellington'})
        end

        it 'should not trigger a db query if there is nothing to unset' do
          record = FactoryBot.create(:record)
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
          @record1 = FactoryBot.create(:record_with_fragment)
          @record1.primary_fragment.job_id = '123'
          @record1.save

          @record2 = FactoryBot.create(:record_with_fragment)
          @record2.primary_fragment.job_id = 'abc'
          @record2.save
        end

        it 'sets status deleted on records with the source_id, but without the given job_id' do
          Record.flush_old_records @record1.primary_fragment.source_id, '123'

          expect(@record1.reload.status).to eq 'active'
          expect(@record2.reload.status).to eq 'deleted'
        end

        it 'sets job_id on deleted records primary fragment with the job_id, so that users know which job deleted the record' do
          @record2.fragments.create(priority: -4, job_id: 'abc', source_id: 'a-sauce-id')
          @record2.fragments.create(priority: -4, job_id: 'abc', source_id: 'b-sauce-id')
          Record.flush_old_records @record1.primary_fragment.source_id, '123'

          @record1.reload
          @record2.reload

          expect(@record2.primary_fragment.job_id).to eq '123'
          @record2.fragments.select { |f| f.priority != 0 }.each do |fragment|
            expect(fragment.job_id).to eq 'abc'
          end

          expect(@record1.primary_fragment.job_id).to eq '123'
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
