# frozen_string_literal: true

# rubocop:disable Rails/Output
module SupplejackApi
  class IndexProcessor
    def initialize(batch_size = 500)
      @batch_size = batch_size
    end

    def call
      index_available_records
      unindex_available_records
    end

    private

    def index_available_records
      p 'Looking for records to index...' unless Rails.env.test?

      indexable_records.batch_size(@batch_size).each_slice(@batch_size) do |records|
        p "[#{Time.current}] #{records.count} to be indexed: #{records.map(&:record_id)}" unless Rails.env.test?
        p "[#{Time.current}] #{records.count} to be indexed: #{records.map(&:updated_at)}" unless Rails.env.test?

        BatchIndexRecords.new(records).call
      end
    end

    def unindex_available_records
      p 'Looking for records to unindex..' unless Rails.env.test?

      unindexable_records.batch_size(@batch_size).each_slice(@batch_size) do |records|
        p "[#{Time.current}] There are #{records.count} records to be removed from the index..." unless Rails.env.test?

        BatchRemoveRecordsFromIndex.new(records).call
      end
    end

    # There are 2 conditions for a record to be ready for indexing
    # 1. The records has been updated and flagged for indexing
    # 2. The record is not part of an active harvest/enrichment job
    def indexable_records
      source_ids = SupplejackApi::AbstractJob.active_job_source_ids

      p "Active source ids #{source_ids}"

      SupplejackApi::Record
        .ready_for_indexing
        .where(
          status: 'active',
          'fragments.source_id' => { '$nin' => source_ids }
        )
    end

    def unindexable_records
      SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active')
    end
  end
end
# rubocop:enable Rails/Output
