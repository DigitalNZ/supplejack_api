# frozen_string_literal: true

module SupplejackApi
  class IndexProcessor
    # rubocop:disable Rails/Output
    def call
      p 'Looking for records to index..' unless Rails.env.test?

      while SupplejackApi::Record.ready_for_indexing.where(status: 'active').count.positive?
        p "There are #{SupplejackApi::Record.ready_for_indexing.where(status: 'active').count} records to be indexed.." unless Rails.env.test?

        BatchIndexRecords.new(SupplejackApi::Record.ready_for_indexing.where(status: 'active').limit(500)).call
      end

      p 'Looking for records to remove..' unless Rails.env.test?

      while SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').count.positive?
        p "There are #{SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').count} records to be removed from the index.." unless Rails.env.test?

        BatchRemoveRecordsFromIndex.new( SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active').limit(500)).call
      end
    end
    # rubocop:enable Rails/Output
  end
end
