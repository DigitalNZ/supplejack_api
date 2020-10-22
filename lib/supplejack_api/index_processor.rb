# frozen_string_literal: true

module SupplejackApi
  class IndexProcessor
    attr_accessor :batch_size

    def initialize(batch_size)
      @batch_size = batch_size || 1000
    end

    def call
      p 'Looking for records to index..'

      records_to_index = SupplejackApi::Record.ready_for_processing.where(status: 'active').limit(batch_size)

      p "There are #{records_to_index.to_a.count} records to be indexed.."

      BatchIndexRecords.new(records_to_index).call

      p 'Looking for records to remove..'

      records_to_remove = SupplejackApi::Record.ready_for_processing.where(:status.ne => 'active').limit(batch_size)

      p "There are #{records_to_remove.to_a.count} records to be removed from the index.."

      BatchRemoveRecordsFromIndex.new(records_to_remove).call
    end
  end
end
