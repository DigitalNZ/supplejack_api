# frozen_string_literal: true

module SupplejackApi
  class IndexProcessor
    # rubocop:disable Rails/Output
    def call
      p 'Looking for records to index..' unless Rails.env.test?

      while SupplejackApi::Record.ready_for_indexing.where(status: 'active').count.positive?

        records = SupplejackApi::Record.ready_for_indexing.where(status: 'active').limit(500).to_a

        p "[#{Time.current}] There are #{records.count} records to be indexed.." unless Rails.env.test?

        BatchIndexRecords.new(records).call
      end

      p 'Looking for records to unindex..' unless Rails.env.test?

      while SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').count.positive?

        records = SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').limit(500).to_a

        p "[#{Time.current}] There are #{records.count} records to be removed from the index.." unless Rails.env.test?

        BatchRemoveRecordsFromIndex.new(records).call
      end
    end
    # rubocop:enable Rails/Output
  end
end
