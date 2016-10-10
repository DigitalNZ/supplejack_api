# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class Story
        include Helpers

        attr_reader :params, :errors

        def initialize(params)
          @params = params
        end

        def get
          story = SupplejackApi::UserSet.custom_find(params[:id])

          return create_exception('StoryNotFound',
                                  { id: params[:id] }) unless story.present?

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def patch
          story = SupplejackApi::UserSet.custom_find(params[:id])
          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::Story, ::StoriesApi::V3::Presenters::Story.new)
          return create_exception('StoryNotFound',
                                  { id: params[:id] }) unless story.present?

          valid = merge_patch.call(story, params[:story])
          return create_exception('SchemaValidationError',
                                  { errors:  merge_patch.validation_errors}) unless valid

          story.save

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def delete
          story = SupplejackApi::UserSet.custom_find(params[:id])

          return create_exception('StoryNotFound',
                                  { id: params[:id] }) unless story.present?

          story.delete

          create_response(status: 204)
        end
      end
    end
  end
end
