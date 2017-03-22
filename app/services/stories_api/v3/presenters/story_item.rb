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
      class StoryItem
        TOP_LEVEL_FIELDS = [:id, :position, :type, :sub_type].freeze
        CUSTOM_PRESENTER_BASE = 'StoriesApi::V3::Presenters::Content'
        DEFAULT_CONTENT_PRESENTER = lambda do |block|
          result = {}

          block.content.each do |k, v|
            result[k] = v
          end

          result
        end

        def call(story_item, story=nil)
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
            result[:meta].merge!({ is_cover: result[:content][:image_url] == story.cover_thumbnail })
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
