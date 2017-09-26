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
      class StoryItem
        include Helpers

        attr_reader :params, :user, :story, :item, :errors

        def initialize(params)
          @params = params
          @user = find_user
          @story = find_story
          @item = find_item
        end

        def get
          return @errors if @errors
          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(item, @story))
        end

        def patch
          return @errors if @errors
          return create_error('MandatoryParamMissing', param: :item) unless params[:item]

          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new,
                                              ::StoriesApi::V3::Presenters::StoryItem.new)

          valid = merge_patch.call(item, params[:item])

          return create_error('SchemaValidationError', errors: merge_patch.validation_errors) unless valid

          item.save

          if params[:item][:meta]
            if params[:item][:meta][:is_cover]
              story.update_attribute(:cover_thumbnail, item.content[:image_url])
            elsif story.cover_thumbnail == item.content[:image_url]
              story.update_attribute(:cover_thumbnail, nil)
            end
          end

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(item))
        end

        def delete
          return @errors if @errors
          item.delete

          if story.cover_thumbnail == item.content[:image_url]
            story.update_attribute(:cover_thumbnail, first_suitable_image(story))
          end


          create_response(status: 204)
        end

        # Initialises user
        #
        # @author Eddie
        # @last_modified Eddie
        def find_user
          user = SupplejackApi::User.find_by_api_key(params[:user_key])
          @errors = create_error('UserNotFound', id: params[:user_key]) unless user
          user
        end

        # Initialises story
        #
        # @author Eddie
        # @last_modified Eddie
        def find_story
          return unless @user
          story = @user.user_sets.find_by_id(params[:story_id])
          @errors = create_error('StoryNotFound', id: params[:story_id]) unless story
          story
        end

        # Initialises story item
        #
        # @author Eddie
        # @last_modified Eddie
        def find_item
          return unless @story
          item = @story.set_items.find_by_id(params[:id])
          @errors = create_error('StoryItemNotFound', item_id: params[:id], story_id: params[:story_id]) unless item
          item
        end
      end
    end
  end
end
