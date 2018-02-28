# frozen_string_literal: true

module StoriesApi
  module V3
    module Presenters
      class Story
        TOP_LEVEL_FIELDS = %i[
          name
          description
          privacy
          copyright
          featured
          featured_at
          approved
          tags
          subjects
          updated_at
          cover_thumbnail
        ].freeze

        def call(story, slim = false)
          result = {}

          TOP_LEVEL_FIELDS.each do |field|
            result[field] = story.send(field)
          end

          result[:id] = story.id.to_s
          result[:number_of_items] = story.set_items.to_a.count { |item| item.type != 'text' }
          result[:creator] = story.user.name

          if slim
            result[:record_ids] = story.set_items.sort_by(&:position).map do |item|
              { record_id: item.record_id, story_item_id: item._id.to_s }
            end
          else
            result[:contents] = story.set_items.sort_by(&:position).map do |item|
              StoriesApi::V3::Presenters::StoryItem.new.call(item, story)
            end
          end

          result
        end

        def self.to_proc
          ->(story) { new.call(story) }
        end
      end
    end
  end
end
