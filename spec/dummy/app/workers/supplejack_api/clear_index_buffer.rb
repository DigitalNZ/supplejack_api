# This is a worker class which gets executed every 5 minutes that pulls any
# records_ids stored in Redis that should be indexed or removed from the 
# index.
#
# Resque Scheduler is used to execute this task.

module SupplejackApi
  class ClearIndexBuffer
    include Sidekiq::Worker
    sidekiq_options queue: 'default', retry: false

    def perform
      Rails.logger.level = 1 unless Rails.env.development?

      session = Sunspot.session
      Sunspot.session = Sunspot::Rails.build_session

      buffer = SupplejackApi::IndexBuffer.new

      index_record_ids = buffer.records_to_index
      if index_record_ids.any?
        Sunspot.index(index_record_ids)
      end

      remove_record_ids = buffer.records_to_remove
      if remove_record_ids.any?
        Sunspot.remove(remove_record_ids)
      end

      Sunspot.commit
    end
  end
end
