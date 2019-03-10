# frozen_string_literal: true

class BatchIndexRecords
  attr_reader :records

  def initialize(records)
    Sunspot.session = Sunspot::Rails.build_session

    @records = records
  end

  def call
    Rails.logger.info "BatchIndexRecords - INDEXING: #{records} records"
    begin
      Sunspot.index(records)
    rescue StandardError
      retry_index_records(records)
    end
  end

  private

  # Call Sunspot index in the array provided, if failure,
  # retry each record individually to be indexed and log errors
  def retry_index_records(records)
    Rails.logger.info 'BatchIndexRecords - INDEXING batch has raised an exception - retrying individual records'
    records.each do |record|
      begin
        Rails.logger.info "BatchIndexRecords - INDEXING: #{record}"
        Sunspot.index record
      rescue StandardError => exception
        Rails.logger.error "BatchIndexRecords - Failed to index record: #{record.inspect} with exception: #{exception.message}"
      end
    end
  end
end
