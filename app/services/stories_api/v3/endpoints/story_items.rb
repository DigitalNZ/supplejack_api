# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class StoryItems
        include Helpers

        attr_reader :params

        def initialize(params)
          @params = params
        end

        def get
          user = params[:user]

          user_account = SupplejackApi::User.find_by_api_key(user)
          return StoriesApi::V3::Errors::UserNotFound.new(params[:user]).error unless user_account.present?

          user_story = user_account.user_sets.find_by_id(params[:id])
          return StoriesApi::V3::Errors::StoryNotFound.new(params[:id]).error unless user_story.present?

          presented_story_items = user_story.set_items.map(&::StoriesApi::V3::Presenters::StoryItem)

          {
            status: 200,
            payload: presented_story_items
          }
        end

      end
    end
  end
end
