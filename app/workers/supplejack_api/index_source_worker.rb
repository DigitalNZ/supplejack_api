# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class IndexSourceWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'default'

    def perform(source_id, date = nil)
      cursor = if date.present?
                 SupplejackApi.config.record_class.where(:'fragments.source_id' => source_id,
                                                         :updated_at.gt => Time.zone.parse(date))
               else
                 SupplejackApi.config.record_class.where('fragments.source_id': source_id)
               end

      in_chunks(cursor.where(status: 'active')) do |records|
        Sunspot.index(records)
      end

      in_chunks(cursor.where(status: 'deleted')) do |records|
        Sunspot.remove(records)
      end
    end

    def in_chunks(cursor)
      total = cursor.count
      start = 0
      chunk_size = 10_000
      while start < total
        records = cursor.limit(chunk_size).skip(start)
        yield records
        start += chunk_size
      end
    end
  end
end
