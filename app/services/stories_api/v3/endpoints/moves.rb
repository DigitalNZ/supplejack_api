# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class Moves
        include Helpers

        REQUIRED_PARAMS = [:story_id, :item_id, :position].freeze
        attr_reader :params, :position, :errors

        def initialize(params)
          @params = params
          @position = params[:position].to_i
        end

        def post
          REQUIRED_PARAMS.each do |param|
            return create_error('MandatoryParamMissing', param: param) unless params.key?(param)
          end
          return create_error(
            'UnsupportedFieldType', value: params[:position], param: 'position'
          ) unless params[:position].is_a?(Integer) || params[:position] =~ /[0-9]+/
          # The above regex does not work on Integers, but if it's an Integer it's guaranteed to be ok
          # So just check that first

          story = current_user(params).user_sets.find_by_id(params[:story_id])
          return create_error('StoryNotFound', id: params[:story_id]) unless story.present?

          set_items = story.set_items.to_a.sort_by(&:position)
          block_to_move_index = set_items.find_index { |x| x.id.to_s == params[:item_id] }

          return create_error('StoryItemNotFound',
                              item_id: params[:item_id],
                              story_id: params[:story_id]) unless block_to_move_index.present?

          if position >= set_items.length
            moved_block = set_items.delete_at(block_to_move_index)
            set_items << moved_block
            updated_items = set_items
          else
            updated_items = set_items.insert(position, set_items.delete_at(block_to_move_index))
          end

          updated_items.each_with_index { |item, index| item.position = index + 1 }

          updated_items.each(&:save!)

          story.cover_thumbnail = first_suitable_image(story) unless story.user_selected_cover
          story.save!

          create_response(status: 200, payload: updated_items.map(&::StoriesApi::V3::Presenters::StoryItem))
        end
      end
    end
  end
end
