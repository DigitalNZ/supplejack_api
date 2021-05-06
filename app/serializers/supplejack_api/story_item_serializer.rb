# frozen_string_literal: true

module SupplejackApi
  class StoryItemSerializer < ActiveModel::Serializer
    attributes :id, :position, :type, :sub_type, :record_id

    attribute :content do
      if object.type == 'embed' && object.sub_type == 'record'
        records_fields
      else
        object.content
      end
    end

    attribute :meta do
      object.meta.merge({ is_cover: object.content[:image_url] == object.user_set.cover_thumbnail })
    end

    private

    def records_fields
      record_fields = {
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
        contributing_partner: :contributing_partner,
        status: :status
      }

      record_id = object[:content][:id]
      record = SupplejackApi.config.record_class.find_by(record_id: record_id) rescue nil
      result = { id: record_id.to_i }

      record_fields.each do |name, field|
        result[name] = record&.public_send(field)
      end

      result[:title] = 'Untitled' if result[:title].nil?

      result[:image_url] = record&.thumbnail_url if result[:image_url].nil?

      # FIXME
      # some records have landing_url ending in 'replace_this'.  This is on the record fragment.
      # Calling record.public_send(:landing_url) calls the method on the fragment, which might have landing_url
      # 'replace_this' depending on how it was harvested.  eg record_id 23036618
      # Strangely, record[:landing_url] returns the correct landing_url, as it is on the mongo record.
      # Landing_url It is not correct on the record model (possibly schema issue)
      # Record fragrment has a complex method_missing implementation which is makign this happen.

      # result[:landing_url] = record[:landing_url] if result[:landing_url].nil?

      result
    end
  end
end
