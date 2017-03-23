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

        attr_reader :params, :user, :story

        def initialize(params)
          @params = params
          @user = SupplejackApi::User.find_by_api_key(params[:api_key])
          @story = @user ? @user.user_sets.find_by_id(params[:story_id]) : nil
        end

        def get
          presented_story_items = @story.set_items.map {|i| StoriesApi::V3::Presenters::StoryItem.new.call(i, @story) }

          create_response(status: 200, payload: presented_story_items)
        end

        def post
          return create_error('MandatoryParamMissing', param: :item) unless params[:item]

          validator = StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(params[:item])
          return create_error('SchemaValidationError',
                              errors: validator.messages(full: true)) unless validator.success?

          item_params = params[:item].deep_symbolize_keys

          # FIXME: This is a temporary fix
          # Can be removed after user_sets is retired
          if item_params[:content][:id]
            item_params[:record_id] = item_params[:content][:id]
            record = SupplejackApi::Record.custom_find(item_params[:record_id])
            item_params[:content][:image_url] = record.large_thumbnail_url || record.thumbnail_url if record
          end

          story_item = story.set_items.build(item_params)
          story.cover_thumbnail = story_item.content[:image_url] unless story.cover_thumbnail
          
          story.save!

          create_response(status: 200,
                          payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(story_item))
        end

        # Returns error if story and user were not initialised
        #
        # @author Eddie
        # @last_modified Eddie
        # @return [Hash] the error
        def errors
          return create_error('UserNotFound', id: params[:api_key]) unless user.present?
          return create_error('StoryNotFound', id: params[:story_id]) unless story.present?
        end
      end
    end
  end
end
