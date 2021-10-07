# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class IndexSourceWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default', retry: false

    def perform(source_id, date = nil)
      Rails.logger.info "IndexSourceWorker - REINDEXING: #{source_id}, date: #{date}"
      cursor = if date.present?
                 SupplejackApi::Record.where(:'fragments.source_id' => source_id,
                                             :updated_at.gt => Time.parse(date).utc)
               else
                 SupplejackApi::Record.where('fragments.source_id': source_id)
               end

      index_records(cursor.where(status: 'active'))
      remove_from_index_records(cursor.where(status: 'deleted'))
    end

    def index_records(cursor)
      start = 0
      chunk_size = SupplejackApi.config.record_batch_size_for_mongo_queries_and_solr_indexing || 500
      total = cursor.count

      while start < total
        records = cursor.limit(chunk_size).skip(start)
        BatchIndexRecords.new(records).call if records.any?
        start += chunk_size
        Rails.logger.info "IndexSourceWorker - REINDEXING: Indexing #{start}/#{records.count} records."
      end
    end

    def remove_from_index_records(cursor)
      start = 0
      chunk_size = SupplejackApi.config.record_batch_size_for_mongo_queries_and_solr_indexing || 500
      total = cursor.count

      while start < total
        records = cursor.limit(chunk_size).skip(start)
        BatchRemoveRecordsFromIndex.new(records).call if records.any?
        start += chunk_size
        Rails.logger.info "IndexSourceWorker - REINDEXING: Removing #{start}/#{records.count} records."
      end
    end
  end
end
