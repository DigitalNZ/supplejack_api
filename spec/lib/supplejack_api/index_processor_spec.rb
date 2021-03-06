require 'spec_helper'

RSpec.describe SupplejackApi::IndexProcessor do
  let(:active_records) { create_list(:record_with_fragment, 5, :ready_for_indexing) }
  let(:deleted_records) { create_list(:record_with_fragment, 5, :ready_for_indexing, :deleted)}
  let(:index_processor)      { SupplejackApi::IndexProcessor.new(20) }

  describe '#attributes' do
    it 'can be initialized with a size' do
      expect(index_processor.size).to eq 20
    end

    it 'has a default size of 1000' do
      expect(SupplejackApi::IndexProcessor.new.size).to eq 1000
    end
  end

  describe '#call' do
    it 'indexes records in batches of the provided size' do
      expect(Sunspot).to receive(:index).with(active_records)
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 5
      index_processor.call
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 0
    end

    it 'removes records in batches of the provided size' do
      expect(Sunspot).to receive(:remove).with(deleted_records)
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 5
      index_processor.call
      expect(SupplejackApi::Record.ready_for_indexing.count).to eq 0
    end
  end
end