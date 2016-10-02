# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class Story
        include Helpers

        attr_reader :params

        def initialize(params)
          @params = params
        end

        def get
          story = SupplejackApi::UserSet.custom_find(params[:id])

          return create_exception(
            status: 404,
            message: 'Story with given Id was not found'
          ) unless story.present?

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def patch
          story = SupplejackApi::UserSet.custom_find(params[:id])
          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::Story, ::StoriesApi::V3::Presenters::Story.new)

          return create_exception(
            status: 404,
            message: 'Story with given Id was not found'
          ) unless story.present?

          valid = merge_patch.call(story, params[:story])

          unless valid
            validation_errors = merge_patch.validation_errors.values.reduce(&:+).join(', ')

            return create_exception(
              status: 400,
              message: "Story patch failed to validate: #{validation_errors}"
            )
          end

          story.save

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def delete
          story = SupplejackApi::UserSet.custom_find(params[:id])

          return create_exception(
            status: 404,
            message: 'Story with given Id was not found'
          ) unless story.present?

          story.delete

          create_response(status: 204)
        end
      end
    end
  end
end
