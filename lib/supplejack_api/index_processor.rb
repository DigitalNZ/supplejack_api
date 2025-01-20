# frozen_string_literal: true

module SupplejackApi
  class IndexProcessor
    def initialize(batch_size = 500)
      @batch_size = batch_size
    end

    def call
      log('Looking for records...')

      clear_query_cache

      index_available_records
      unindex_available_records
    end

    private

    def clear_query_cache
      Mongoid.default_client.close
      Mongoid.default_client.reconnect
    end

    def index_available_records
      indexable_records.batch_size(@batch_size).each_slice(@batch_size) do |records|
        log("#{records.count} to be indexed: #{records.map(&:record_id)}", true)

        BatchIndexRecords.new(records).call
      end
    end

    def unindex_available_records
      unindexable_records.batch_size(@batch_size).each_slice(@batch_size) do |records|
        log("#{records.count} to be unindexed: #{records.map(&:record_id)}", true)

        BatchRemoveRecordsFromIndex.new(records).call
      end
    end

    # There are 2 conditions for a record to be ready for indexing
    # 1. The records has been updated and flagged for indexing
    # 2. The record is not part of an active harvest/enrichment job
    def indexable_records
      log "Active source ids #{source_ids}"

      SupplejackApi::Record
        .ready_for_indexing
        .where(
          status: 'active',
          'fragments.source_id' => { '$nin' => source_ids }
        )
    end

    def unindexable_records
      log "Active source ids #{source_ids}"

      SupplejackApi::Record
        .ready_for_indexing
        .where(
          :status.ne => 'active',
          'fragments.source_id' => { '$nin' => source_ids }
        )
    end

    def source_ids
      # coming from the worker
      worker_source_ids = []
      worker_source_ids = AbstractJob.active_job_source_ids if ENV['WORKER_HOST'].present?
      # coming from the harvester
      api_source_ids = Source.where(harvesting: true)

      (api_source_ids.map(&:source_id) + worker_source_ids).uniq
    end

    def log(str, prefix = '')
      return if Rails.env.test?

      prefix = "[#{Time.current}] [#{Process.pid}/#{Process.ppid}] " if prefix.present?
      puts "#{prefix}#{str}"
    end
  end
end
