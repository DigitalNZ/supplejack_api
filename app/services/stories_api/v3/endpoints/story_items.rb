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
      class StoryItems
        include Helpers

        attr_reader :params, :user, :story, :errors

        def initialize(params)
          @params = params
          @item_params = params[:item]&.deep_symbolize_keys
          @user = SupplejackApi::User.find_by_api_key(params[:user_key])

          if @user
            @story = @user.user_sets.find_by_id(params[:story_id])
            @errors = create_error('StoryNotFound', id: params[:story_id]) unless @story.present?
          else
            @errors = create_error('UserNotFound', id: params[:user_key]) unless @user
          end
        end

        def get
          return @errors if @errors
          presented_story_items = @story.set_items.map { |i| StoriesApi::V3::Presenters::StoryItem.new.call(i, @story) }

          create_response(status: 200, payload: presented_story_items)
        end

        def post
          return @errors if @errors
          return create_error('MandatoryParamMissing', param: :item) unless params[:item]

          position = @item_params.delete(:position)

          validator = StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(params[:item])
          return create_error('SchemaValidationError', errors: validator.messages(full: true)) unless validator.success?

          story_item = story.set_items.build(@item_params)
          story.cover_thumbnail = story_item.content[:image_url] unless story.cover_thumbnail
          story.save!

          if position
            StoriesApi::V3::Endpoints::Moves.new(story_id: story.id.to_s,
                                                 user_key: user.api_key,
                                                 item_id: story_item.id.to_s,
                                                 position: position).post
            story_item.reload
          end

          create_response(status: 200,
                          payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(story_item))
        end

        private

        def text_item?
          @item_params[:type] == 'text'
        end
      end
    end
  end
end
