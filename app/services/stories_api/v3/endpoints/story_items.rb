# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class StoryItems
        include Helpers

        attr_reader :params, :user, :story

        def initialize(params)
          @params = params
          @user = SupplejackApi::User.find_by_api_key(params[:user])
          @story = @user ? @user.user_sets.find_by_id(params[:id]) : nil
        end

        def get
          presented_story_items = @story.set_items.map(&::StoriesApi::V3::Presenters::StoryItem)

          create_response(status: 200, payload: presented_story_items)
        end

        def post
          validator = StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(params[:block])
          return create_exception('SchemaValidationError',
                                  errors: validator.messages(full: true)) unless validator.success?
          
          story_items = story.set_items.build(params[:block])
          story.save!

          create_response(status: 200,
                          payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(story_items))
        end

        def put
          params[:blocks].each do |block|
            validator = StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(block)
            return create_exception('SchemaValidationError',
                                    errors: validator.messages(full: true)) unless validator.success?
          end

          @story.set_items.destroy

          params[:blocks].each do |block|
            story.set_items.build(block)
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
          return create_exception('UserNotFound', { id: params[:user] }) unless user.present?
          return create_exception('StoryNotFound', { id: params[:id] }) unless story.present?
        end
      end
    end
  end
end
