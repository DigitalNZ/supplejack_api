# frozen_string_literal: true

class IndexProcessor
  attr_accessor :batch_size

  def initialize(batch_size)
    @batch_size = batch_size
  end

  def call
    p 'Looking for records to index..'

    records_to_index = SupplejackApi::Record.any_of({ '$where' => 'this.processed_at < this.updated_at' }, processed_at: nil).where(status: 'active').limit(batch_size)

    BatchIndexRecords.new(records_to_index).call

    p 'Looking for records to remove..'

    records_to_remove = SupplejackApi::Record.any_of({ '$where' => 'this.processed_at < this.updated_at' }, processed_at: nil).where(:status.ne => 'active').limit(batch_size)

    BatchRemoveRecordsFromIndex.new(records_to_remove).call
  end
end
