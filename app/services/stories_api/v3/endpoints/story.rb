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

        attr_reader :params, :errors

        def initialize(params)
          @params = params
        end

        def get
          story = SupplejackApi::UserSet.custom_find(params[:id])


          if story.privacy == 'private'
            if params[:user_key].nil?
              return create_error('PrivateStoryRequiresUserKey', id: params[:id])
            else
              # todo
            end
          end

          return create_error('StoryNotFound',
                              id: params[:id]) unless story.present?

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def patch
          Rails.logger.info 'Stories Issues'
          story = SupplejackApi::UserSet.custom_find(params[:id])
          Rails.logger.info "Stories Issues: story #{story}"
          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::Story, ::StoriesApi::V3::Presenters::Story.new)
          return create_error('StoryNotFound',
                              id: params[:id]) unless story.present?

          valid = merge_patch.call(story, params[:story])
          Rails.logger.info "Stories Issues valid #{valid}"
          Rails.logger.info "Stories Issues: message #{merge_patch.validation_errors}" unless valid
          return create_error('SchemaValidationError',
                              errors:  merge_patch.validation_errors) unless valid

          story.save

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(story))
        end

        def delete
          story = SupplejackApi::UserSet.custom_find(params[:id])

          return create_error('StoryNotFound',
                              id: params[:id]) unless story.present?

          story.delete

          create_response(status: 204)
        end
      end
    end
  end
end
