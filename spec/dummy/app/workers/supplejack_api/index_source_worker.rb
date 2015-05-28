# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class IndexSourceWorker
    @queue = :index_source

    def self.perform(source_id, date=nil)
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

    def self.in_chunks(cursor, &block)
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
