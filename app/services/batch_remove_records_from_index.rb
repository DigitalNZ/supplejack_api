# frozen_string_literal: true

class BatchRemoveRecordsFromIndex
  attr_reader :records

  def initialize(records)
    Sunspot.session = Sunspot::Rails.build_session

    @records = records
  end

  def call
    Sunspot.remove(records)
  rescue StandardError
    retry_remove_records(records)
  end

  private

  # Call Sunspot remove in the array provided, if failure,
  # retry each record individually to be removed and log errors
  def retry_remove_records(records)
    Rails.logger.info 'BatchRemoveRecordsFromIndex - REMOVE INDEX batch has raised an exception - retrying individual records'
    records.each do |record|
      begin
        Rails.logger.info "BatchRemoveRecordsFromIndex - REMOVE INDEX: #{record}"
        Sunspot.remove record
      rescue StandardError => exception
        Rails.logger.error "BatchRemoveRecordsFromIndex - Failed to remove index record: #{record.inspect} with exception: #{exception.message}"
      end
    end
  end
end
