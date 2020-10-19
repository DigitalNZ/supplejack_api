# frozen_string_literal: true

class BatchIndexRecords
  attr_reader :records

  def initialize(records)
    Sunspot.session = Sunspot::Rails.build_session

    @records = records
  end

  # to_a is called on the records because Mongoid critieria 
  # does not apply the limit until the query happens
  # so without `to_a` everything that matches gets updated
  def call
    Sunspot.index(records.to_a)
    p "Updating records... #{records.count}"

    # This is to avoid excessive writes to Mongo
    SupplejackApi::Record.where(:record_id.in => records.map(&:record_id)).update_all(processed_at: Time.current)
  rescue StandardError => e
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
    p 'Record has errored'
    Sunspot.index record
    p 'Updating failed record'
    record.update(processed_at: Time.now.utc)
  rescue StandardError => e
    p 'Record completely failed'
    Rails.logger.error "BatchIndexRecords - Failed to index: #{record.inspect} - #{e.message}"
  end
end
