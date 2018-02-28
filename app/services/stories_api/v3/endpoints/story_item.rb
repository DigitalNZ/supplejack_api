# frozen_string_literal: true

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

          valid = merge_patch.call(item, item_params)

          return create_error('SchemaValidationError', errors: merge_patch.validation_errors) unless valid

          item.save

          if item_params[:meta]
            if item_params[:meta][:is_cover]
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

        private

        def item_params
          @item_params ||= params.require(:item).permit(:title,
                                                        :position,
                                                        :type,
                                                        :sub_type,
                                                        content: [:id,
                                                                  :title,
                                                                  :display_collection,
                                                                  :value,
                                                                  :image_url,
                                                                  category: [],
                                                                  tags: []],
                                                        meta: %i[align_mode is_cover caption title size metadata]).to_h
        end
      end
    end
  end
end
