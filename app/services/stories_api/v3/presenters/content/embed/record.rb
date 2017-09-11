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
              landing_url: :landing_url,
              tags: :tag,
              description: :description,
              content_partner: :content_partner,
              creator: :creator,
              rights: :rights,
              contributing_partner: :contributing_partner
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

              # FIXME
              # some records have landing_url ending in 'replace_this'.  This is on the record fragment.
              # Calling record.public_send(:landing_url) calls the method on the fragment, which might have landing_url
              # 'replace_this' depending on how it was harvested.  eg record_id 23036618
              # Strangely, record[:landing_url] returns the correct landing_url, as it is on the mongo record.
              # Landing_url It is not correct on the record model (possibly schema issue)
              # Record fragrment has a complex method_missing implementation which is makign this happen.
              result[:landing_url] = record[:landing_url]

              result
            end
          end
        end
      end
    end
  end
end
