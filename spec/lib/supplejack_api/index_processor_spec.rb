# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::IndexProcessor do
  let(:active_records) { create_list(:record_with_fragment, 5, :ready_for_indexing) }
  let(:deleted_records) { create_list(:record_with_fragment, 5, :ready_for_indexing, :deleted) }

  before do
    allow(SupplejackApi::AbstractJob).to receive(:active_job_source_ids).and_return([])
  end

  describe '#call' do
    it 'indexes records in batches of the provided size' do
      expect(Sunspot).to receive(:index).with(active_records)
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 5

      sleep 5 # required as the index processor picks up records created 5 seconds ago

      described_class.new.call

      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 0
    end

    it 'removes records in batches of the provided size' do
      expect(Sunspot).to receive(:remove).with(deleted_records)
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 5

      described_class.new.call

      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 0
    end

    it 'does not index records related to harvesting source_id' do
      create(:record, fragments: [build(:record_fragment, source_id: 'hello')])
      create(:source, source_id: 'hello', harvesting: true)

      expect(Sunspot).to receive(:index).with(active_records)
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 6

      sleep 5 # required as the index processor picks up records created 5 seconds ago

      described_class.new.call

      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 1
    end

    context 'when no records are changed' do
      it 'does not update the invalidation token' do
        expect(SupplejackApi::IndexInvalidation).not_to receive(:update_token)
        described_class.new.call
      end
    end

    context 'when no records are ready for indexing' do
      it 'does not update the invalidation token' do
        expect(SupplejackApi::IndexInvalidation).not_to receive(:update_token)
        described_class.new.call
      end
    end
  end
end
