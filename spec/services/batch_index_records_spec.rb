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
    context 'when sunspot does not raise exception on indexing in bulk' do
      before { expect(Sunspot).to receive(:index).with(records) }

      it 'updates index_updated & index_updated_at on all records' do
        BatchIndexRecords.new(records).call

        records.map(&:reload)

        expect(records.map(&:index_updated)).to all(be(true))
        expect(records.map(&:index_updated_at)).to all(be_a(Date))
      end
    end

    context 'when sunspot raises exception on indexing in bulk' do
      before { allow(Sunspot).to receive(:index).with(records).and_raise }

      it 'tries to index each individual record if any exception was raised' do
        records.each { |record| expect(Sunspot).to receive(:index).with(record) }

        BatchIndexRecords.new(records).call
      end

      it 'updates index_updated & index_updated_at on all records' do
        records.each { |record| allow(Sunspot).to receive(:index).with(record) }

        BatchIndexRecords.new(records).call

        records.map(&:reload)

        expect(records.map(&:index_updated)).to all(be(true))
        expect(records.map(&:index_updated_at)).to all(be_a(Date))
      end
    end
  end
end
