# frozen_string_literal: true

class BatchRemoveRecordsFromIndex
  attr_reader :records

  def initialize(records)
    Sunspot.session = Sunspot::Rails.build_session

    @records = records
  end

  def call
    Sunspot.remove(records.to_a) if records.any?

    SupplejackApi::Record.where(:record_id.in => records.map(&:record_id)).update_all(index_updated: true, index_updated_at: Time.current)
  rescue StandardError
    retry_remove_records(records)
  end

  private

  # Call Sunspot remove in the array provided, if failure,
  # retry each record individually to be removed and log errors
  def retry_remove_records(records)
    Rails.logger.info 'BatchRemoveRecordsFromIndex - REMOVE INDEX ERROR - retrying individual records'
    records.each do |record|
      Rails.logger.info "BatchRemoveRecordsFromIndex - REMOVE INDEX: #{record}"
      Sunspot.remove record
      record.update(index_updated: true, index_updated_at: Time.current)
    rescue StandardError => e
      Rails.logger.error "BatchRemoveRecordsFromIndex - Failed to remove: #{record.inspect} - #{e.message}"
    end
  end
end
