# frozen_string_literal: true
module StoriesApi
  module V3
    module Presenters
      module Content
        module Embed
          class Dnz
            RECORD_FIELDS = [:id, :title, :display_collection, :category, :image_url, :tags].freeze

            def call(block)
              record = SupplejackApi::Record.find_by(id: block[:content][:record_id])
              result = { record_id: block[:content][:record_id], record: {} }

              RECORD_FIELDS.each do |field|
                result[:record][field] = record[field]
              end

              result
            end
          end
        end
      end
    end
  end
end
