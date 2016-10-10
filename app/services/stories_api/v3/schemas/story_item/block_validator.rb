# frozen_string_literal: true
module StoriesApi
  module V3
    module Schemas
      module StoryItem
        class BlockValidator
          # Returns result
          # PerformMergePatch calls .success? on the result of this method
          # SetItems end point checks success after the call is made
          #
          # @author Taylor
          # @last_modified Eddie
          # @return [Hash] the error
          def call(block)
            story_item_block = StoriesApi::V3::Schemas::StoryItem::Block.new.call(block)
            return story_item_block unless story_item_block.success?

            type = block[:type].classify
            sub_type = block[:sub_type].classify
            block_schema = "StoriesApi::V3::Schemas::StoryItem::#{type}::#{sub_type}".constantize
            
            block_schema.call(block)
          end
        end
      end
    end
  end
end
