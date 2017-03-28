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
          Rails.logger.info 'COVER THUMB'
          Rails.logger.info "COVER THUMB: params: #{params}"
          return @errors if @errors
          return create_error('MandatoryParamMissing', param: :item) unless params[:item]

          merge_patch = PerformMergePatch.new(::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new,
                                              ::StoriesApi::V3::Presenters::StoryItem.new)

          Rails.logger.info "COVER THUMB: params item #{params[:item]}"

          Rails.logger.info "COVER THUMB: item before: #{item}"

          valid = merge_patch.call(item, params[:item])

          Rails.logger.info "COVER THUMB: valid? #{valid}"
          Rails.logger.info "COVER THUMB: valid? #{merge_patch.validation_errors}" unless valid

          return create_error('SchemaValidationError', errors: merge_patch.validation_errors) unless valid

          item.save

          Rails.logger.info "COVER THUMB: item after: #{item}"

          if params[:item][:meta]
            Rails.logger.info "COVER THUMB: has meta #{params[:item][:meta]}"
            if params[:item][:meta][:is_cover]
              Rails.logger.info "COVER THUMB: has is_cover"
              Rails.logger.info "COVER THUMB: image_url : #{item.content}"
              story.update_attribute(:cover_thumbnail, item.content[:image_url])
            elsif story.cover_thumbnail == item.content[:image_url]
              Rails.logger.info "COVER THUMB: dont have is_cover"
              story.update_attribute(:cover_thumbnail, nil)
            end
          end

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::StoryItem.new.call(item))
        end

        def delete
          return @errors if @errors
          story.update_attribute(:cover_thumbnail, nil) if story.cover_thumbnail == item.content[:image_url]

          item.delete

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

# params:
#   { item: {
#       position: 1,
#       meta: { is_cover:false, align_mode: 1, caption: "This is a test"},
#       content: { 
#         i: 23376598, title: "Cricket match on a sunny afternoon",
#         display_collection: "mychillybin.co.nz",
#         category: ["Images"],
#         image_url: "http://www.mychillybin.co.nz/viewphoto/mychillybin100116/mychillybin100116_1693/w/mychillybin100116_1693.jpg"
#         tags: nil, description: nil, content_partner: ["mychillybin"]
#         },
#       type: "embed",
#       sub_type: "dnz"
#       },
#     api_key: "bES4B3UwR64cP8msCphF",
#     debug: true,
#     user_key: "QAZV1i__KK2PPjuE1zsc",
#     version: nil,
#     story_id: "58d34258297b1f027a000000",
#     story_item: {"item"=>{"position"=>1, "meta"=>{"is_cover"=>false, "align_mode"=>1, "caption"=>"This is a test"}, "content"=>{"id"=>23376598, "title"=>"Cricket match on a sunny afternoon", "display_collection"=>"mychillybin.co.nz", "category"=>["Images"], "image_url"=>"http://www.mychillybin.co.nz/viewphoto/mychillybin100116/mychillybin100116_1693/w/mychillybin100116_1693.jpg", "tags"=>nil, "description"=>nil, "content_partner"=>["mychillybin"]}, "type"=>"embed", "sub_type"=>"dnz"}}}










