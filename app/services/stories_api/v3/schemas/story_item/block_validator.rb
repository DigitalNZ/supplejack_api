# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module StoriesApi
  module V3
    module Schemas
      module StoryItem
        class BlockValidator
          # Returns an object of the validation
          #
          # @author Taylor
          # @last_modified Eddie
          # @return [Object] the validation

          def call(block)
            story_item_block = StoriesApi::V3::Schemas::StoryItem::Block.new.call(block)
            return story_item_block unless story_item_block.success?

            type = block[:type].classify
            sub_type = block[:sub_type].tr('-', '_').classify
            block_schema = "StoriesApi::V3::Schemas::StoryItem::#{type}::#{sub_type}".constantize

            block_schema.call(block)
          end
        end
      end
    end
  end
end
