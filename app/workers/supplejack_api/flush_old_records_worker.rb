 module SupplejackApi
  class FlushOldRecordsWorker

    @queue = :flush_records

    def self.perform(source_id, job_id)
      Record.flush_old_records(source_id, job_id)
    end
  end
end