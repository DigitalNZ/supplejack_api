

 module SupplejackApi
  class FlushOldRecordsWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default'

    def perform(source_id, job_id)
      SupplejackApi.config.record_class.flush_old_records(source_id, job_id)
    end
  end
end
