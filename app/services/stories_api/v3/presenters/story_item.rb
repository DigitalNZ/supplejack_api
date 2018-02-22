# frozen_string_literal: true



module StoriesApi
  module V3
    module Presenters
      class StoryItem
        TOP_LEVEL_FIELDS = %i[id position type sub_type].freeze
        CUSTOM_PRESENTER_BASE = 'StoriesApi::V3::Presenters::Content'
        DEFAULT_CONTENT_PRESENTER = lambda do |block|
          result = {}

          block.content.each do |k, v|
            result[k] = v
          end

          result
        end

        def call(story_item, story = nil)
          result = {}

          result[:record_id] = story_item.record_id if story_item.record_id

          TOP_LEVEL_FIELDS.each do |field|
            result[field] = story_item.send(field)
          end
          # FIXME
          result[:id] = result[:id].to_s

          type = story_item[:type].classify
          sub_type = story_item[:sub_type].classify
          content_presenter = (
            "#{CUSTOM_PRESENTER_BASE}::#{type}::#{sub_type}".constantize.new rescue DEFAULT_CONTENT_PRESENTER
          )

          result[:content] = content_presenter.call(story_item)

          result[:meta] = {}
          story_item.meta.each do |k, v|
            result[:meta][k] = v
          end

          if story
            # This will override the value of is_cover in database
            result[:meta][:is_cover] = (result[:content][:image_url] == story.cover_thumbnail)
          end

          result
        end

        def self.to_proc
          ->(story_item) { new.call(story_item) }
        end
      end
    end
  end
end
