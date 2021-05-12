# frozen_string_literal: true

module SupplejackApi
  class IndexProcessor
    attr_accessor :size

    def initialize(size = 1000)
      @size = size
    end

    # rubocop:disable Rails/Output
    def call
      p 'Looking for records to index..' unless Rails.env.test?

      while SupplejackApi::Record.ready_for_indexing.where(status: 'active').count.positive?
        p "There are #{SupplejackApi::Record.ready_for_indexing.where(status: 'active').count} records to be indexed.." unless Rails.env.test?

        records = SupplejackApi::Record.ready_for_indexing.where(status: 'active').limit(500)

        BatchIndexRecords.new(records.compact).call
      end

      p 'Looking for records to remove..' unless Rails.env.test?

      while SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').count.positive?
        p "There are #{SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').count} records to be removed from the index.." unless Rails.env.test?

        records = SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').limit(500)

        BatchRemoveRecordsFromIndex.new(records.compact).call
      end
    end
    # rubocop:enable Rails/Output
  end
end