# frozen_string_literal: true

module SupplejackApi
  class IndexProcessor
    def call
      index_available_records

      unindex_available_records
    end

    # rubocop:disable Rails/Output
    def index_available_records
      p 'Looking for records to index..' unless Rails.env.test?

      available_records = indexable_records

      while available_records.count.positive?
        records = available_records.limit(500).to_a

        p "[#{Time.current}] There are #{records.count} records to be indexed.." unless Rails.env.test?
        p "[#{Time.current}] Index records #{records.map(&:record_id)}" unless Rails.env.test?

        BatchIndexRecords.new(records).call

        available_records = indexable_records
      end
    end

    def unindex_available_records
      p 'Looking for records to unindex..' unless Rails.env.test?

      available_records = SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active')

      while available_records.count.positive?
        records = available_records.limit(500).to_a

        p "[#{Time.current}] There are #{records.count} records to be removed from the index.." unless Rails.env.test?

        BatchRemoveRecordsFromIndex.new(records).call

        available_records = SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active')
      end
    end
    # rubocop:enable Rails/Output

    # There are 2 conditions for a record to be ready for indexing
    # 1. The records has been updated and flagged for indexing
    # 2. The record is not part of an active harvest/enrichment job
    def indexable_records
      source_ids = SupplejackApi::AbstractJob.active_job_source_ids
      SupplejackApi::Record.ready_for_indexing.where(status: 'active', :source_id.nin => source_ids)
    end
  end
end
