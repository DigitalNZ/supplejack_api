# frozen_string_literal: true

# Handles the logic for storing and retreiving record_ids from Redis
# which should be indexed or removed from Solr.

module SupplejackApi
  class RecordRedisQueue
    # Pops record ids to be indexed/unindexed from redis list
    def pop_record_ids(method = :index, batch_size = 1000)
      result = OpenStruct.new(ids: [])
      number_of_ids = count_for_buffer_type(method)

      # rubocop:disable LineLength
      Rails.logger.info "INDEXING[#{Time.zone.now.strftime('%d/%m/%y %H:%M:%S')}]: #{number_of_ids} ids in #{method} buffer" if number_of_ids.positive?
      # rubocop:enable LineLength

      Sidekiq.redis do |conn|
        conn.pipelined do
          buffer = buffer_name(method)
          range_end = [number_of_ids, batch_size].min
          result.ids = conn.lrange(buffer, 0, range_end - 1)

          # keeping everything from range_end to last entry
          conn.ltrim(buffer, range_end, -1)
        end
      end

      # Removimg duplicate entries
      result.ids.value.uniq || []
    end

    # Fetches records to be indexed
    def records_to_index
      records = SupplejackApi.config.record_class.where(:id.in => pop_record_ids(:index)).to_a
      records.keep_if(&:should_index?)
      records
    end

    # Fetches records to be unindexed
    def records_to_remove
      records = SupplejackApi.config.record_class.where(:id.in => pop_record_ids(:remove)).to_a
      records.delete_if(&:should_index?)
      records
    end

    # Dynamically creating 2 methods to insert redords ids
    # to be indexed/unindexed
    %i[index remove].each do |method|
      define_method("push_to_#{method}_buffer") do |ids|
        Sidekiq.redis do |conn|
          conn.pipelined do
            ids.each do |id|
              conn.rpush(buffer_name(method), id)
            end
          end
        end
      end
    end

    private

    # Returns count of record ids in redis list
    def count_for_buffer_type(type)
      Sidekiq.redis do |conn|
        conn.llen(buffer_name(type))
      end
    end

    # Returns the name of redis key for index list
    def buffer_name(type)
      "#{type}_buffer_record_ids"
    end
  end
end
