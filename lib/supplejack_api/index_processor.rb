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

      # mem = GetProcessMem.new
      # puts "Before the mock indexing.. #{mem.mb}"

      # 5.times do
      #   SupplejackApi::Record.ready_for_indexing.where(status: 'active').count

      #   p "I am indexing records ... "
      # end

      # puts "After the mock indexing ... #{mem.mb}"

      mem = GetProcessMem.new
      puts "Before the while loop #{mem.mb}"

      while SupplejackApi::Record.ready_for_indexing.where(status: 'active').count.positive?
        # puts "Before the count #{mem.mb}"

        p "There are #{SupplejackApi::Record.ready_for_indexing.where(status: 'active').count} records to be indexed.." unless Rails.env.test?
      
        # puts "Before sending to the index job #{mem.mb}"

        BatchIndexRecords.new(SupplejackApi::Record.ready_for_indexing.where(status: 'active').limit(500)).call

        # puts "After Batch Index Records #{mem.mb}"
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