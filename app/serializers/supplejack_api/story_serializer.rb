# frozen_string_literal: true

module SupplejackApi
  class StorySerializer < ActiveModel::Serializer
    attributes %i[id name description privacy copyright
                  featured featured_at approved tags state
                  subjects updated_at cover_thumbnail]

    has_many :contents, serializer: StoryItemSerializer, unless: -> { scope[:slim] }

    attribute :creator do
      object.user.name
    end

    attribute :user_id do
      object.user.id
    end

    attribute :number_of_items do
      items.reject { |item| item.type == 'text' }.count
    end

    attribute :record_ids, if: -> { scope[:slim] } do
      items.sort_by { |i| i.position.to_i }.map do |item|
        { record_id: item.record_id, story_item_id: item._id.to_s }
      end
    end

    attribute :category do
      cover_item = items.detect do |set_item|
        set_item.meta[:is_cover] == true && set_item['type'] != 'text'
      end

      if cover_item.present?
        cover_item.content[:category]&.first || 'Other'
      else
        fake_cover_item = items.detect { |set_item| set_item.type != 'text' }
        fake_cover_item.present? ? fake_cover_item.content[:category]&.first || 'Other' : 'Other'
      end
    end

    private

    def items
      object.set_items
    end
  end
end
