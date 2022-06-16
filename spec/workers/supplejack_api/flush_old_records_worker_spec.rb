# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe FlushOldRecordsWorker do
    describe '#perform' do
      it 'calls flush_records' do
        flush_old_records_worker = FlushOldRecordsWorker.new
        allow(flush_old_records_worker).to receive(:perform).and_call_original

        expect(flush_old_records_worker).to receive(:flush_records).with('source', '123')

        flush_old_records_worker.perform('source', '123')
      end

      it 'calls BatchRemoveRecordsFromIndex service for all deleted records for a given source_id' do
        fragments = build_list(:record_fragment, 1, priority: 0, job_id: '999', source_id: 'source')
        create_list(:record, 10, status: 'active', fragments: fragments)

        mongo_criteria = SupplejackApi::Record.deleted.where('fragments.source_id': 'source').limit(500).skip(0)

        expect(BatchRemoveRecordsFromIndex).to receive(:new).with(mongo_criteria).and_call_original

        FlushOldRecordsWorker.new.perform('source', '123')
      end
    end

    describe '#flush_records' do
      current_job_id = '123'
      old_job_id = '999'
      source_id = 'a-source-id'

      let!(:active_record) do
        fragments = build_list(:record_fragment, 1,
                               priority: 0,
                               job_id: old_job_id,
                               source_id: source_id)
        create(:record, status: 'active', fragments: fragments)
      end

      let!(:suppressed_record) do
        fragments = build_list(:record_fragment, 1, priority: 0, job_id: old_job_id, source_id: source_id)
        create(:record, status: 'suppressed', fragments: fragments)
      end

      let!(:deleted_record) do
        fragments = build_list(:record_fragment, 1, priority: 0, job_id: old_job_id, source_id: source_id)
        create(:record, status: 'deleted', fragments: fragments)
      end

      let!(:active_record_other_job) do
        fragments = build_list(:record_fragment, 1,
                               priority: 0,
                               job_id: current_job_id,
                               source_id: source_id,
                               title: 'other')

        create(:record, status: 'active', fragments: fragments)
      end

      it 'should delete all active/suppressed records that were not harvest by a specific job' do
        FlushOldRecordsWorker.new.flush_records(source_id, current_job_id)
        expect(SupplejackApi::Record.deleted.count).to eq 3
      end
    end
  end
end
