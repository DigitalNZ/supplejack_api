# frozen_string_literal: true

module StoriesApi
  module V3
    module Endpoints
      class Stories
        include Helpers

        attr_reader :params, :errors, :user

        def initialize(params)
          @params = params
          @user = current_user(params)
        end

        def get
          return create_error('UserNotFound', id: params[:user_key]) if user.blank?

          slim = params[:slim] != 'false'

          presented_stories = user.user_sets.order_by(updated_at: 'desc').map do |user_set|
            ::StoriesApi::V3::Presenters::Story.new.call(user_set, slim)
          end

          create_response(status: 200, payload: presented_stories)
        end

        def post
          return create_error('UserNotFound', id: params[:user_key]) if user.blank?
          return create_error('MandatoryParamMissing', param: :name) if story_params.blank?

          new_story = user.user_sets.create(name: story_params[:name])

          if new_story.valid?
            create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(new_story))
          else
            create_response(status: 400, payload: "Story not saved: #{new_story.errors}")
          end
        end

        private

        def story_params
          @story_params ||= params.require(:story).permit(:name).to_h
        rescue StandardError
          false
        end
      end
    end
  end
end
