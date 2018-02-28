# frozen_string_literal: true

module StoriesApi
  module V3
    module Endpoints
      class Story
        include Helpers

        attr_reader :params, :errors, :user

        def initialize(params)
          @params = params
          # user from user_key, not api_key
          @user = current_user(params)
        end

        def get
          story = SupplejackApi::UserSet.custom_find(params[:id])

          return create_error('StoryNotFound', id: params[:id]) if story.blank?

          if story.privacy == 'private'
            return create_error('PrivateStoryNotAuthorised', id: params[:id]) unless user
            unless story.user == user || user.admin?
              return create_error('PrivateStoryNotAuthorised', id: params[:id])
            end
          end

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def patch
          story = if @user.admin?
                    ::SupplejackApi::UserSet.custom_find(params[:id])
                  else
                    strip_admin_params
                    @user.user_sets.custom_find(params[:id])
                  end

          return create_error('StoryNotFound', id: params[:id]) if story.blank?

          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::Story, ::StoriesApi::V3::Presenters::Story.new)

          valid = merge_patch.call(story, params[:story])
          return create_error('SchemaValidationError', errors:  merge_patch.validation_errors) unless valid

          story.save

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def delete
          story = user.user_sets.custom_find(params[:id])

          return create_error('StoryNotFound', id: params[:id]) if story.blank?

          story.delete

          create_response(status: 204)
        end

        private

        def strip_admin_params
          %i[approved featured].each do |field|
            @params[:story].delete(field) if @params[:story].present?
          end
        end
      end
    end
  end
end
