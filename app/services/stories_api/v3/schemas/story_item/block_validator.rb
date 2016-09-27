# frozen_string_literal: true
module StoriesApi
  module V3
    module Schemas
      module StoryItem
        class BlockValidator
          def call(block)
            type = block[:type].classify
            sub_type = block[:sub_type].classify

            block_schema = "StoriesApi::V3::Schemas::StoryItem::#{type}::#{sub_type}".constantize

            block_schema.call(block).success?
          end
        end
      end
    end
  end
end
