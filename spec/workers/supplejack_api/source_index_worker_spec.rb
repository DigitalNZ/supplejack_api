# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe IndexSourceWorker do
    # rubocop:disable Style/HashSyntax
    describe '.perform' do
      let(:records) { [FactoryBot.create(:record_with_fragment), FactoryBot.create(:record_with_fragment)] }

      before do
        records.each do |r|
          r.primary_fragment.source_id = 'source_id'
          r.save
        end

        allow(Record).to receive(:where).with(hash_including(:'fragments.source_id' => 'source_id')).and_call_original
      end

      it 'finds all active records and indexes them' do
        expect(Record).to receive(:where).with(:'fragments.source_id' => 'source_id').and_call_original
        expect(BatchIndexRecords).to receive(:new).with(records).and_call_original

        IndexSourceWorker.new.perform('source_id')
      end

      it 'finds all deleted records and removes them from solr' do
        records.each { |r| r.update_attribute(:status, 'deleted') }

        expect(Record).to receive(:where).with(:'fragments.source_id' => 'source_id').and_call_original
        expect(BatchRemoveRecordsFromIndex).to receive(:new).with(records).and_call_original
        IndexSourceWorker.new.perform('source_id')
      end

      it 'finds records updated more recently than the date given' do
        date = Time.now.utc
        allow(Time).to receive(:parse) { date }
        expect(Record).to receive(:where)
          .with(:'fragments.source_id' => 'source_id', :updated_at.gt => Time.parse(date.to_s).utc)

        IndexSourceWorker.new.perform('source_id', date.to_s)
      end
    end
    # rubocop:enable Style/HashSyntax
  end
end
