require "spec_helper"

module SupplejackApi
  describe IndexSourceWorker do
    describe ".perform" do
      let(:records) { [FactoryBot.create(:record_with_fragment), FactoryBot.create(:record_with_fragment)] }

      before do
        records.each do |r|
          r.primary_fragment.source_id = 'source_id'
          r.save
        end

        allow(Record).to receive(:where).with(hash_including(:'fragments.source_id' => 'source_id')).and_call_original
      end

      it "finds all active records and indexes them" do
        expect(Record).to receive(:where).with(:'fragments.source_id' => 'source_id').and_call_original
        expect(Sunspot).to receive(:index).with(records)

        IndexSourceWorker.new.perform('source_id')
      end

      it "finds all deleted records and removes them from solr" do
        records.each { |r| r.update_attribute(:status, 'deleted') }

        expect(Record).to receive(:where).with(:'fragments.source_id' => 'source_id').and_call_original
        expect(Sunspot).to receive(:remove).with(records)
        IndexSourceWorker.new.perform('source_id')
      end

      it "finds records updated more recently than the date given" do
        date = Time.now
        allow(Time).to receive(:parse) { date }
        expect(Record).to receive(:where).with(:'fragments.source_id' => 'source_id', :updated_at.gt => Time.zone.parse(date.to_s))
        IndexSourceWorker.new.perform('source_id', date.to_s)
      end
    end

    describe ".in_chunks" do
      let(:records) { [double(:record), double(:record)] }

      it "gets a chunk of records and yields to block" do
        mock_cursor = double(:cursor)
        mock_cursor_2 = double(:cursor)
        expect(mock_cursor).to receive(:limit).with(500) {mock_cursor_2}
        expect(mock_cursor).to receive(:count) {2}
        expect(mock_cursor_2).to receive(:skip).with(0) { records }

        expect{|b| IndexSourceWorker.new.in_chunks(mock_cursor, &b) }.to yield_with_args(records)
      end
    end
  end
end
