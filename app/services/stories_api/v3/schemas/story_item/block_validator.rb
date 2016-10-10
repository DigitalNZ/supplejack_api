# frozen_string_literal: true
module StoriesApi
  module V3
    module Schemas
      module StoryItem
        class BlockValidator
          attr_reader :messages, :result, :valid

          def initialize
            @messages = nil
            @valid = true
          end

          # Returns result
          # PerformMergePatch calls .success? on the result of this method
          # SetItems end point checks success after the call is made
          # 
          # @author Taylor
          # @last_modified Eddie
          # @return [Hash] the error
          def call(block)
            [:type, :sub_type].each do |param|
              unless block[param]
                @messages = V3::Errors::MandatoryParamMissing.new(param).error
                @valid = false
                return false
              end
            end

            block_object = StoriesApi::V3::Schemas::StoryItem::Block.new

            unless block_object.valid_types.include? block[:type]
              @messages = V3::Errors::UnsupportedFieldType.new(:type, block[:type]).error
              @valid = false
              return false
            end

            unless block_object.valid_sub_types.include? block[:sub_type]
              @messages = V3::Errors::UnsupportedFieldType.new(:sub_type, block[:sub_type]).error
              @valid = false
              return false
            end

            type = block[:type].classify
            sub_type = block[:sub_type].classify
            block_schema = "StoriesApi::V3::Schemas::StoryItem::#{type}::#{sub_type}".constantize
            @result = block_schema.call(block)

            unless result.success?
              @messages = V3::Errors::SchemaValidationError.new(result.messages(full: true)).error
              @valid = false
            end

            @result
          end

          def success?
            @valid
          end
        end
      end
    end
  end
end
