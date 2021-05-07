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
      result[:landing_url] = record[:landing_url] if result[:landing_url].nil?

      result
    end
  end
end
