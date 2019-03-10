# frozen_string_literal: true

# This is a worker class which gets executed every 5 minutes that pulls any
# records_ids stored in Redis that should be indexed or removed from the
# index.
#
# Resque Scheduler is used to execute this task.

module SupplejackApi
  class IndexRemainingRecordsInQueue
    include Sidekiq::Worker
    sidekiq_options queue: 'default', retry: false

    def perform
      Rails.logger.level = 1 unless Rails.env.development?

      buffer = SupplejackApi::RecordRedisQueue.new

      records_to_index = buffer.records_to_index
      BatchIndexRecords.new(records_to_index).call if records_to_index.any?

      records_to_remove = buffer.records_to_remove
      BatchRemoveFromIndexRecords.new(records_to_remove).call if records_to_remove.any?
    end
  end
end
