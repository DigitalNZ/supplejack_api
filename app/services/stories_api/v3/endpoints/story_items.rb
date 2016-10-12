# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class StoryItems
        include Helpers

        attr_reader :params, :user, :story

        def initialize(params)
          @params = params
          @user = SupplejackApi::User.find_by_api_key(params[:api_key])
          @story = @user ? @user.user_sets.find_by_id(params[:story_id]) : nil
        end

        def get
          presented_story_items = @story.set_items.map(&::StoriesApi::V3::Presenters::StoryItem)

          create_response(status: 200, payload: presented_story_items)
        end

        def post
          return create_exception('MandatoryParamMissing', param: :block) unless params[:block]
          
          validator = StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(params[:block])
          return create_exception('SchemaValidationError',
                                  errors: validator.messages(full: true)) unless validator.success?

          story_item = story.set_items.build(params[:block].deep_symbolize_keys)
          story.save!

          create_response(status: 200,
                          payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(story_item))
        end

        # Not using this method now
        def put
          params[:blocks].each do |block|
            validator = StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(block)
            return create_exception('SchemaValidationError',
                                    errors: validator.messages(full: true)) unless validator.success?
          end

          @story.set_items.destroy

          params[:blocks].each do |block|
            story.set_items.build(block.deep_symbolize_keys)
          end

          story.save!

          presented_story_items = @story.set_items.map(&::StoriesApi::V3::Presenters::StoryItem)

          create_response(status: 200, payload: presented_story_items)
        end

        # Returns error if story and user were not initialised
        #
        # @author Eddie
        # @last_modified Eddie
        # @return [Hash] the error
        def errors
          return create_exception('UserNotFound', id: params[:api_key]) unless user.present?
          return create_exception('StoryNotFound', id: params[:story_id]) unless story.present?
        end
      end
    end
  end
end
