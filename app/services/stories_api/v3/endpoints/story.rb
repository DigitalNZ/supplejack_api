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

          unless story.present?
            return {
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
              }
            }
          end

          {
            status: 200,
            payload: ::StoriesApi::V3::Presenters::Story.new.call(story)
          }
        end

        def patch
          story = SupplejackApi::UserSet.custom_find(params[:id])
          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::Story, ::StoriesApi::V3::Presenters::Story.new)

          unless story.present?
            return {
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
              }
            }
          end

          valid = merge_patch.call(story, params[:story])

          unless valid
            validation_errors = merge_patch.validation_errors.values.reduce(&:+).join(', ')

            return {
              status: 400,
              exception: {
                message: "Story patch failed to validate: #{validation_errors}"
              }
            }
          end

          story.save

          {
            status: 200,
            payload: ::StoriesApi::V3::Presenters::Story.new.call(story)
          }
        end

        def delete
          story = SupplejackApi::UserSet.custom_find(params[:id])

          unless story.present?
            return {
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
              }
            }
          end

          story.delete

          {
            status: 204
          }
        end
      end
    end
  end
end
