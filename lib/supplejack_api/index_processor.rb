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

      available_records = records_ready_5_secods_ago

      while available_records.count.positive?
        records = available_records.limit(500).to_a

        p "[#{Time.current}] There are #{records.count} records to be indexed.." unless Rails.env.test?
        p "[#{Time.current}] Index records #{records.map(&:record_id)}" unless Rails.env.test?

        BatchIndexRecords.new(records).call

        available_records = records_ready_5_secods_ago
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

    # This query is made to counter a race condition.
    # If a second can be broken down to 3 parts and if the following happens in those 3 parts sequentially.
    # - Enrichment 1 updates record x
    # - IndexProcessor pics up the record x
    # - Enrichment 2 updates record x
    # The second update wont be captured on indexing as the updated_at for both enrichments are at the same second.
    # So if we query ready_for_indexing with a delay of 5 seconds we make sure that
    # both updates written in any second is captured
    def records_ready_5_secods_ago
      SupplejackApi::Record.ready_for_indexing.where(status: 'active', :updated_at.lte => (Time.current - 5.seconds))
    end
  end
end
