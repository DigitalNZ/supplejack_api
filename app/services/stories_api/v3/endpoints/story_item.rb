# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class StoryItem
        include Helpers

        attr_reader :params, :user, :story, :item

        def initialize(params)
          @params = params
          @user = SupplejackApi::User.find_by_api_key(params[:user])
          @story = @user ? @user.user_sets.find_by_id(params[:story_id]) : nil
          @item = @story ? @story.set_items.find_by_id(params[:id]) : nil
        end

        def patch
          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new,
                                              ::StoriesApi::V3::Presenters::StoryItem.new)

          valid = merge_patch.call(item, params[:item])

          return V3::Errors::SchemaValidationError.new(merge_patch.validation_errors).error unless valid

          item.save

          {
            status: 200,
            payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(item)
          }          
        end

        def delete
          item.delete

          { status: 204 }
        end

        # Returns error if story and user were not initialised
        #
        # @author Eddie
        # @last_modified Eddie
        # @return [Hash] the error
        def errors
          return V3::Errors::UserNotFound.new(params[:user]).error unless user.present?
          return V3::Errors::StoryNotFound.new(params[:story_id]).error unless story.present?
          return V3::Errors::StoryItemNotFound.new(params[:id], params[:story_id]).error unless item.present?
        end
      end
    end
  end
end
