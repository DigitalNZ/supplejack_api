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
            [:type, :sub_type].each do |param|
              unless block[param]
                @messages = V3::Errors::MandatoryParamMissing.new(param).error
                return false
              end
            end

            block_object = StoriesApi::V3::Schemas::StoryItem::Block.new

            unless block_object.valid_types.include? block[:type]
              @messages = V3::Errors::UnsupportedFieldType.new(:type, block[:type]).error
              return false
            end

            unless block_object.valid_sub_types.include? block[:sub_type]
              @messages = V3::Errors::UnsupportedFieldType.new(:sub_type, block[:sub_type]).error
              return false
            end

            type = block[:type].classify
            sub_type = block[:sub_type].classify

            block_schema = "StoriesApi::V3::Schemas::StoryItem::#{type}::#{sub_type}".constantize
            result = block_schema.call(block)

            @messages = V3::Errors::SchemaValidationError.new(result.messages).error
            result.success?
          end
        end
      end
    end
  end
end
