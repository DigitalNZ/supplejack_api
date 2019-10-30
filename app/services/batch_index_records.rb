# frozen_string_literal: true

class BatchIndexRecords
  attr_reader :records

  def initialize(records)
    Sunspot.session = Sunspot::Rails.build_session

    @records = records
  end

  def call
    Sunspot.index(records)
  rescue StandardError
    retry_index_records(records)
  end

  private

  # Call Sunspot index in the array provided, if failure,
  # retry each record individually to be indexed and log errors
  def retry_index_records(records)
    Rails.logger.info 'BatchIndexRecords - INDEXING batch has raised an exception - retrying individual records'
    records.each { |record| index_individual_record(record) }
  end

  def index_individual_record(record)
    Rails.logger.info "BatchIndexRecords - INDEXING: #{record}"
    Sunspot.index record
  rescue StandardError => e
    Rails.logger.error "BatchIndexRecords - Failed to index: #{record.inspect} - #{e.message}"
  end
end
