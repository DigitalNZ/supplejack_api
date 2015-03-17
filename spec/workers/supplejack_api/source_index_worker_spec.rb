# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require "spec_helper"

module SupplejackApi
  describe IndexSourceWorker do
    describe ".perform" do
      let(:records) { [FactoryGirl.create(:record_with_fragment), FactoryGirl.create(:record_with_fragment)] }

      before do
        records.each do |r|
          r.primary_fragment.source_id = 'tapuhi'
          r.save
        end

        allow(Record).to receive(:where).with(hash_including(:'fragments.source_id' => 'tapuhi')).and_call_original
      end

      it "finds all active records and indexes them" do
        expect(Record).to receive(:where).with(:'fragments.source_id' => 'tapuhi').and_call_original
        expect(Sunspot).to receive(:index).with(records)
        IndexSourceWorker.perform('tapuhi')
      end
      

      it "finds all deleted records and removes them from solr" do
        records.each { |r| r.update_attribute(:status, 'deleted') }

        expect(Record).to receive(:where).with(:'fragments.source_id' => 'tapuhi').and_call_original
        expect(Sunspot).to receive(:remove).with(records)
        IndexSourceWorker.perform('tapuhi')
      end

      it "finds records updated more recently than the date given" do
        date = Time.now
        allow(Time).to receive(:parse) { date }
        expect(Record).to receive(:where).with(:'fragments.source_id' => 'tapuhi', :updated_at.gt => date)
        IndexSourceWorker.perform('tapuhi', date.to_s)
      end
    end

    describe ".in_chunks" do
      let(:records) { [double(:record), double(:record)] }

      it "gets a chunk of records and yields to block" do
        mock_cursor = double(:cursor)
        mock_cursor_2 = double(:cursor)
        expect(mock_cursor).to receive(:limit).with(10000) {mock_cursor_2}
        expect(mock_cursor).to receive(:count) {2}
        expect(mock_cursor_2).to receive(:skip).with(0) { records }

        expect{|b| IndexSourceWorker.in_chunks(mock_cursor, &b) }.to yield_with_args(records)
      end
    end
  end
end