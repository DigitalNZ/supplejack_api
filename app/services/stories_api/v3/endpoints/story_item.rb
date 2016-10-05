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
        end

        def delete
        end

        # Returns error if story and user were not initialised
        #
        # @author Eddie
        # @last_modified Eddie
        # @return [Hash] the error
        def errors
          return V3::Errors::UserNotFound.new(params[:user]).error unless user.present?
          return V3::Errors::StoryNotFound.new(params[:story_id]).error unless story.present?
          return V3::Errors::StoryItemNotFound.new(params[:id], params[:story_id]).error unless story.present?
        end
      end
    end
  end
end
