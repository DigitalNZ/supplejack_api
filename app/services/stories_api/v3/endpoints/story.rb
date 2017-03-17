# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module StoriesApi
  module V3
    module Endpoints
      class Story
        include Helpers

        attr_reader :params, :errors, :user

        def initialize(params)
          @params = params
          @user = current_user(params)
        end

        def get
          story = SupplejackApi::UserSet.custom_find(params[:id])

          return create_error('StoryNotFound',
                              id: params[:id]) unless story.present?

          if story.privacy == 'private'
            return create_error('PrivateStoryNotAuthorised', id: params[:id]) unless user
             
            unless story.user == user || user.admin?
              return create_error('PrivateStoryNotAuthorised', id: params[:id])
            end
          end

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def patch
          story = user.user_sets.custom_find(params[:id])

          return create_error('StoryNotFound',
                              id: params[:id]) unless story.present?

          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::Story, ::StoriesApi::V3::Presenters::Story.new)

          valid = merge_patch.call(story, params[:story])
          return create_error('SchemaValidationError',
                              errors:  merge_patch.validation_errors) unless valid

          story.save

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def delete
          story = user.user_sets.custom_find(params[:id])

          return create_error('StoryNotFound',
                              id: params[:id]) unless story.present?

          story.delete

          create_response(status: 204)
        end
      end
    end
  end
end
