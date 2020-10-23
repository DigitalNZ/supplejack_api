# frozen_string_literal: true

module SupplejackApi
  class IndexProcessor
    attr_accessor :size

    def initialize(size = 1000)
      @size = size
    end

    def call
      loop do
        p 'Looking for records to index..' unless Rails.env.test?

        records_to_index = SupplejackApi::Record.ready_for_indexing.where(status: 'active')

        records_to_index.in_groups_of(size).each do |records|
          p "There are #{records_to_index.to_a.count} records to be indexed.." unless Rails.env.test?

          BatchIndexRecords.new(records.compact).call
        end

        p 'Looking for records to remove..'

        records_to_remove = SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active')

        records_to_remove.in_groups_of(size).each do |records|
          p "There are #{records_to_remove.to_a.count} records to be removed from the index.." unless Rails.env.test?

          BatchRemoveRecordsFromIndex.new(records.compact).call
        end

        p 'Checking if remaining records are above the threshold...' unless Rails.env.test?

        records_to_index = SupplejackApi::Record.ready_for_indexing.where(status: 'active')
        records_to_remove = SupplejackApi::Record.ready_for_indexing.where(:status.ne => 'active')

        if records_to_index.count < 100 && records_to_remove.count < 100
          p 'There are not enough records at the moment. Will try again soon...' unless Rails.env.test?
          break
        else
          p 'Continuing to index records...' unless Rails.env.test?
        end
      end
    end
  end
end
