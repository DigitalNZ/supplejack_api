

 module SupplejackApi
  class FlushOldRecordsWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default'

    def perform(source_id, job_id)
      SupplejackApi::Record.flush_old_records(source_id, job_id)
    end
  end
end
