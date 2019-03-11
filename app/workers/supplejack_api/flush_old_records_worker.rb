# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  # app/workers/supplejack_api/flush_old_records_worker.rb
  class FlushOldRecordsWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default', retry: false

    def perform(source_id, job_id)
      flush_records(source_id, job_id)

      cursor = SupplejackApi.config.record_class.deleted.where('fragments.source_id': source_id)

      start = 0
      chunk_size = 500

      total = cursor.count

      while start < total
        records = cursor.limit(chunk_size).skip(start)
        BatchRemoveFromIndexRecords.new(records).call
        Rails.logger.info "FlushOldRecordsWorker - FULL-AND-FLUSH: Removing #{start}/#{records.count} records."
        start += chunk_size
      end
      Rails.logger.info "FlushOldRecordsWorker - FULL-AND-FLUSH: Done  #{total}/#{records.count} records."
    end

    # Delete all active and suppressed records from a source_id that hasn't been harvested by a specific job
    def flush_records(source_id, job_id)
      Rails.logger.info "FlushOldRecordsWorker - FULL-AND-FLUSH: source_id: #{source_id} -- job_id: #{job_id}"
      SupplejackApi.config.record_class.where(
        :'fragments.source_id' => source_id,
        :'fragments.job_id'.ne => job_id,
        :status.in => %w[active supressed],
        'fragments.priority': 0
      ).update_all(status: 'deleted', updated_at: Time.zone.now,
                   '$set': { 'fragments.$.job_id' => job_id })
    end
  end
end
