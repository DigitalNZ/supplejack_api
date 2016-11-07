# frozen_string_literal: true
module StoriesApi
  module V3
    module Presenters
      module Content
        module Embed
          class Dnz
            RECORD_FIELDS = {title: :title , display_collection: :display_collection, category: :category, image_url: :large_thumbnail_url, tags: :tag }.freeze

            def call(block)
              record = SupplejackApi::Record.find_by(record_id: block[:content][:record_id])
              result = { record_id: block[:content][:record_id], record: {} }

              RECORD_FIELDS.each do |name, field|
                result[:record][name] = record.public_send(field)
              end

              result
            end
          end
        end
      end
    end
  end
end
