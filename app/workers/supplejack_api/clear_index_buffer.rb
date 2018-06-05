# frozen_string_literal: true

# This is a worker class which gets executed every 5 minutes that pulls any
# records_ids stored in Redis that should be indexed or removed from the
# index.
#
# Resque Scheduler is used to execute this task.

module SupplejackApi
  class ClearIndexBuffer
    include Sidekiq::Worker
    sidekiq_options queue: 'default', retry: false

    # rubocop:disable Style/GuardClause
    def perform
      Rails.logger.level = 1 unless Rails.env.development?

      Sunspot.session = Sunspot::Rails.build_session

      buffer = SupplejackApi::IndexBuffer.new

      records_to_index = buffer.records_to_index
      if records_to_index.any?
        Rails.logger.info "INDEXING: #{records_to_index.count} records"
        begin
          Sunspot.index(records_to_index)
        rescue StandardError
          retry_index_records(records_to_index)
        end
      end

      records_to_remove = buffer.records_to_remove
      if records_to_remove.any?
        Rails.logger.info "UN-INDEXING: #{records_to_remove.count} records"
        begin
          Sunspot.remove(records_to_remove)
        rescue StandardError
          retry_remove_records(records_to_remove)
        end
      end
    end

    private

    # Call Sunspot index in the array provided, if failure,
    # retry each record individually to be indexed and log errors
    def retry_index_records(records)
      Rails.logger.warn 'INDEXING batch has raised an exception - retrying individual records'
      records.each do |record|
        begin
          Rails.logger.info "INDEXING: #{record}"
          Sunspot.index record
        rescue StandardError => exception
          Rails.logger.error "Failed to index record: #{record.inspect} with exception: #{exception.message}"
        end
      end
    end

    # Call Sunspot remove in the array provided, if failure,
    # retry each record individually to be removed and log errors
    def retry_remove_records(records)
      Rails.logger.warn 'REMOVE INDEX batch has raised an exception - retrying individual records'
      records.each do |record|
        begin
          Rails.logger.info "REMOVE INDEX: #{record}"
          Sunspot.remove record
        rescue StandardError => exception
          Rails.logger.error "Failed to remove index record: #{record.inspect} with exception: #{exception.message}"
        end
      end
    end
  end
end
