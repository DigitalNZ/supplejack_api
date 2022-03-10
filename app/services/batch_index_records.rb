# frozen_string_literal: true

class BatchIndexRecords
  attr_reader :records

  def initialize(records)
    Sunspot.session = Sunspot::Rails.build_session

    @records = records
  end

  def call
    Sunspot.index(records) if records.any?

    update_unless_changed(records)
  rescue StandardError
    retry_index_records(records)
  end

  private

  # rubocop:disable Rails/Output
  # Call Sunspot index in the array provided, if failure,
  # retry each record individually to be indexed and log errors
  def retry_index_records(records)
    p 'BatchIndexRecords - INDEXING batch has raised an exception - retrying individual records'

    records.each { |record| index_individual_record(record) }
  end

  def index_individual_record(record)
    p "BatchIndexRecords - INDEXING: #{record.record_id}"

    Sunspot.index record

    update_unless_changed([record])
  rescue StandardError => e
    p "BatchIndexRecords - Failed to index Record #{record.record_id}: #{record.inspect} - #{e.message}"

    update_unless_changed([record])
  end
  # rubocop:enable Rails/Output

  def update_unless_changed(records)
    SupplejackApi::Record.where(
      :record_id.in => records.map(&:record_id),
      :updated_at.in => records.map(&:updated_at)
    ).update_all(index_updated: true, index_updated_at: Time.current)
  end
end
