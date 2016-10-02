# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class StoryItems
        include Helpers

        attr_reader :params, :user, :story

        def initialize(params)
          @params = params
          set_user_and_story
        end

        def get
          return V3::Errors::UserNotFound.new(params[:user]).error unless @user.present?
          return V3::Errors::StoryNotFound.new(params[:id]).error unless @story.present?

          presented_story_items = @story.set_items.map(&::StoriesApi::V3::Presenters::StoryItem)

          {
            status: 200,
            payload: presented_story_items
          }
        end

        def post
          return V3::Errors::UserNotFound.new(params[:user]).error unless @user.present?
          return V3::Errors::StoryNotFound.new(params[:id]).error unless @story.present?
        end

        private

        def set_user_and_story
          user = params[:user]

          @user = SupplejackApi::User.find_by_api_key(user)
          @story = @user ? @user.user_sets.find_by_id(params[:id]) : nil
        end
      end
    end
  end
end
