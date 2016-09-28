# frozen_string_literal: true
module StoriesApi
  module V3
    module Presenters
      class Story
        TOP_LEVEL_FIELDS = [
          :id,
          :name,
          :description,
          :privacy,
          :featured,
          :approved,
          :tags
        ].freeze

        def call(story)
          result = {}

          TOP_LEVEL_FIELDS.each do |field|
            result[field] = story.send(field)
          end
          result[:number_of_items] = story.set_items.count
          result[:contents] = story.set_items.map(&StoryItem)

          result
        end
      end
    end
  end
end
