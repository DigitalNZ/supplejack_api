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

        Record.stub(:where).with(hash_including(:'fragments.source_id' => 'tapuhi')).and_call_original
      end

      it "finds all active records and indexes them" do
        Record.should_receive(:where).with(:'fragments.source_id' => 'tapuhi').and_call_original
        Mongoid::Criteria.any_instance.should_receive(:active).and_call_original

        Sunspot.should_receive(:index).with(records)
        IndexSourceWorker.perform('tapuhi')
      end
      

      it "finds all deleted records and removes them from solr" do
        records.each { |r| r.update_attribute(:status, 'deleted') }

        Record.should_receive(:where).with(:'fragments.source_id' => 'tapuhi').and_call_original
        Mongoid::Criteria.any_instance.should_receive(:deleted).and_call_original

        Sunspot.should_receive(:remove).with(records)
        IndexSourceWorker.perform('tapuhi')
      end

      it "finds records updated more recently than the date given" do
        date = Time.now
        Time.stub(:parse) {date}
        Record.should_receive(:where).with(:'fragments.source_id' => 'tapuhi', :updated_at.gt => date)
        IndexSourceWorker.perform('tapuhi', date.to_s)
      end
    end

    describe ".in_chunks" do
      let(:records) { [double(:record), double(:record)] }

      it "gets a chunk of records and yields to block" do
        mock_cursor = double(:cursor)
        mock_cursor_2 = double(:cursor)
        mock_cursor.should_receive(:limit).with(10000) {mock_cursor_2}
        mock_cursor.should_receive(:count) {2}
        mock_cursor_2.should_receive(:skip).with(0) { records }

        expect{|b| IndexSourceWorker.in_chunks(mock_cursor, &b) }.to yield_with_args(records)
      end
    end
  end
end