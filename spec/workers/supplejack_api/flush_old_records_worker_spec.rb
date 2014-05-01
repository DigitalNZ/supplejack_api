require "spec_helper"

module SupplejackApi
  describe FlushOldRecordsWorker do

    describe "perform" do
      it "should call 'flush_old_records' on Record with the given source_id & job_id" do
        Record.should_receive(:flush_old_records).with("abc-123", "abc123")
        FlushOldRecordsWorker.perform("abc-123", "abc123")
      end
    end
  end
end