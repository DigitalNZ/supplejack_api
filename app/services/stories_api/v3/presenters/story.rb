# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module StoriesApi
  module V3
    module Presenters
      class Story
        TOP_LEVEL_FIELDS = [
          :name,
          :description,
          :privacy,
          :copyright,
          :featured,
          :approved,
          :tags,
          :updated_at
        ].freeze

        def call(story, slim = false)
          result = {}

          TOP_LEVEL_FIELDS.each do |field|
            result[field] = story.send(field)
          end
          result[:id] = story.id.to_s
          result[:number_of_items] = story.set_items.count
          result[:cover_thumbnail] = first_suitable_image story
          if slim
            result[:record_ids] = story.set_items.sort_by(&:position).map { |x| { record_id: x.record_id } }
          else
            result[:contents] = story.set_items.sort_by(&:position).map(&StoryItem)
          end
          result
        end

        def first_suitable_image(story)
          item_with_image = story.set_items.sort_by(&:position).detect { |item|
            item.content.present? && (item.type == 'embed') && (item.sub_type == 'dnz') && (item.content[:image_url].present?)
          }

          item_with_image.content[:image_url] unless item_with_image.nil?
        end

        def self.to_proc
          ->(story) { new.call(story) }
        end
      end
    end
  end
end
