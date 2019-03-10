# frozen_string_literal: true

class BatchRemoveFromIndexRecords
  attr_reader :records

  def initialize(records)
    Sunspot.session = Sunspot::Rails.build_session

    @records = records
  end

  def call
    Rails.logger.info "BatchRemoveFromIndex - UN-INDEXING: #{records.count} records"
    begin
      Sunspot.remove(records)
    rescue StandardError
      retry_remove_records(records)
    end
  end

  private

  # Call Sunspot remove in the array provided, if failure,
  # retry each record individually to be removed and log errors
  def retry_remove_records(records)
    Rails.logger.info 'BatchRemoveFromIndex - REMOVE INDEX batch has raised an exception - retrying individual records'
    records.each do |record|
      begin
        Rails.logger.info "BatchRemoveFromIndex - REMOVE INDEX: #{record}"
        Sunspot.remove record
      rescue StandardError => exception
        Rails.logger.error "BatchRemoveFromIndex - Failed to remove index record: #{record.inspect} with exception: #{exception.message}"
      end
    end
  end
end
