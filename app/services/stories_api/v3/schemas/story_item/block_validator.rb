# frozen_string_literal: true
module StoriesApi
  module V3
    module Schemas
      module StoryItem
        class BlockValidator
          attr_reader :messages

          def initialize
            @messages = nil
          end

          def call(block)
            type = block[:type].classify
            sub_type = block[:sub_type].classify

            block_schema = "StoriesApi::V3::Schemas::StoryItem::#{type}::#{sub_type}".constantize
            result = block_schema.call(block)

            @messages = result.messages
            result.success?
          end
        end
      end
    end
  end
end
