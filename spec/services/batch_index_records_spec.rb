# frozen_string_literal: true

RSpec.describe BatchIndexRecords do
  let(:records) { create_list(:record_with_fragment, 10, :ready_for_indexing) }

  describe '#initialize' do
    it 'Set Sunspot.session to post directly to solr' do
      BatchIndexRecords.new(records)

      expect(Sunspot.session.class).to eq Sunspot::Rails.build_session.class
    end
  end

  describe '#call' do
    it 'calls Sunspot.index with the array of records passed via args' do
      expect(Sunspot).to receive(:index).with(records)

      BatchIndexRecords.new(records).call
      records.map(&:reload)
      expect(records.map(&:index_updated)).to all(be(true))
      expect(records.map(&:index_updated_at)).to all(be_a(Date))
    end

    it 'tries to index each individual record if any exception was raised' do
      allow(Sunspot).to receive(:index).with(records).and_raise

      records.each do |record|
        expect(Sunspot).to receive(:index).with(record)
      end

      BatchIndexRecords.new(records).call
    end
  end
end
