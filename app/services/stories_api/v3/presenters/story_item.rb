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

        def call(story_item)
          result = {}

          result[:record_id] = story_item.record_id if story_item.record_id

          TOP_LEVEL_FIELDS.each do |field|
            result[field] = story_item.send(field)
          end

          story_item.content.each do |k, v|
            result[:content] ||= {}
            result[:content][k] = v
          end

          result[:meta] = {}
          story_item.meta.each do |k, v|
            result[:meta][k] = v
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
