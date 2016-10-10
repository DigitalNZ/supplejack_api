# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class StoryItem
        include Helpers

        attr_reader :params, :user, :story, :item, :errors

        def initialize(params)
          @params = params
          @user = SupplejackApi::User.find_by_api_key(params[:user])
          @story = @user ? @user.user_sets.find_by_id(params[:story_id]) : nil
          @item = @story ? @story.set_items.find_by_id(params[:id]) : nil
          @errors = []
        end

        def patch
          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new,
                                              ::StoriesApi::V3::Presenters::StoryItem.new)

          valid = merge_patch.call(item, params[:item])

          return create_exception('SchemaValidationError', { errors: merge_patch.validation_errors }) unless valid

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
          return create_exception('UserNotFound', { id: params[:user] }) unless user.present?
          return create_exception('StoryNotFound', { id: params[:story_id] }) unless story.present?
          return create_exception('StoryItemNotFound', { item_id: params[:id], story_id: params[:story_id] }) unless item.present?
        end
      end
    end
  end
end
