# frozen_string_literal: true

RSpec.describe BatchRemoveRecordsFromIndex do
  describe '#initialize' do
    let!(:active_record) { FactoryBot.create_list(:record_with_fragment, 10) }

    it 'Set Sunspot.session to post directly to solr' do
      BatchRemoveRecordsFromIndex.new(SupplejackApi::Record.all)

      expect(Sunspot.session.class).to eq Sunspot::Rails.build_session.class
    end
  end

  describe '#call' do
    let!(:active_record) { FactoryBot.create_list(:record_with_fragment, 10, :ready_for_indexing) }

    it 'calls Sunspot.remove with the array of records passed via args' do
      expect(Sunspot).to receive(:remove).with(SupplejackApi::Record.all)

      BatchRemoveRecordsFromIndex.new(SupplejackApi::Record.all).call
      active_record.map(&:reload)
      expect(active_record.map(&:index_updated)).to all(be(true))
      expect(active_record.map(&:index_updated_at)).to all(be_a(Date))
    end

    it 'tries to remove from index each individual record if any exception is raised' do
      allow(Sunspot).to receive(:remove).with(SupplejackApi::Record.all).and_raise

      expect(Sunspot).to receive(:remove).with(SupplejackApi::Record).exactly(10).times

      BatchRemoveRecordsFromIndex.new(SupplejackApi::Record.all).call
    end
  end
end
