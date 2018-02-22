

module SupplejackApi
  class IndexSourceWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default'

    def perform(source_id, date=nil)
      if date.present?
        cursor = Record.where(:'fragments.source_id' => source_id, :updated_at.gt => Time.parse(date))
      else
        cursor = Record.where(:'fragments.source_id' => source_id)
      end

      in_chunks(cursor.where(status: "active")) do |records|
        Sunspot.index(records)
      end

      in_chunks(cursor.where(status: "deleted")) do |records|
        Sunspot.remove(records)
      end
    end

    def in_chunks(cursor, &block)
      total = cursor.count
      start = 0
      chunk_size = 10000
      while start < total
        records = cursor.limit(chunk_size).skip(start)
        yield records
        start += chunk_size
      end
    end
  end
end
