# frozen_string_literal: true
module StoriesApi
  module V3
    module Presenters
      module Content
        module Embed
          class Record
            RECORD_FIELDS = {
              title: :title,
              display_collection: :display_collection,
              category: :category,
              image_url: :large_thumbnail_url,
              tags: :tag,
              description: :description,
              content_partner: :content_partner
            }.freeze

            def call(block)
              # FIXME
              # This is because I changed from record_id to id after Eddy migrated
              # all the existing user sets
              record_id = block[:content][:id] || block[:content][:record_id]
              record = SupplejackApi::Record.find_by(record_id: record_id) rescue nil
              result = { id: record_id.to_i }

              RECORD_FIELDS.each do |name, field|
                result[name] = record&.public_send(field)
              end

              result[:image_url] = record&.thumbnail_url if result[:image_url].nil?

              result
            end
          end
        end
      end
    end
  end
end
