module StoriesApi
  module V3
    module Presenters
      class StoryItem
        TOP_LEVEL_FIELDS = [:position, :type, :sub_type]

        def call(story_item)
          result = {}

          TOP_LEVEL_FIELDS.each do |field|
            result[field] = story_item.send(field)
          end

          story_item.content.each do |k, v|
            result[:content] ||= {}
            result[:content][k] = v
          end

          story_item.meta.each do |k, v|
            result[:meta] ||= {}
            result[:meta][k] = v
          end

          result
        end
      end
    end
  end
end
