# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class Stories
        include Helpers

        attr_reader :params

        def initialize(params)
          @params = params
        end

        def get
          user = params[:user]
          user_account = SupplejackApi::User.find_by_api_key(user)

          unless user_account.present?
            return {
              status: 404,
              exception: {
                message: 'User with provided Id was not found'
              }
            }
          end

          presented_stories = user_account.user_sets.map(&::StoriesApi::V3::Presenters::Story)

          {
            status: 200,
            payload: presented_stories
          }
        end

        def post
          story_name = params[:story][:name]

          unless story_name.present?
            return {
              status: 400,
              exception: {
                message: 'Story was missing name field'
              }
            }
          end

          new_story = current_user(params).user_sets.create(name: story_name)

          {
            status: 200,
            payload: ::StoriesApi::V3::Presenters::Story.new.call(new_story)
          }
        end
      end
    end
  end
end
