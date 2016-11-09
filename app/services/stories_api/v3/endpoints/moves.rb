# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class Moves
        include Helpers

        REQUIRED_PARAMS = [:story_id, :item_id, :item_to_move_to_id].freeze
        attr_reader :params, :position, :errors

        def initialize(params)
          @params = params
          @position = params[:position].to_i
        end

        def post
          REQUIRED_PARAMS.each do |param|
            return create_error('MandatoryParamMissing', param: param) unless params.key?(param)
          end

          story = current_user(params).user_sets.find_by_id(params[:story_id])
          return create_error('StoryNotFound', id: params[:story_id]) unless story.present?

          block_to_move_index = story.set_items.find_index { |item| item.id.to_s == params[:item_id] }
          index_to_move_to = story.set_items.find_index { |item| item.id.to_s == params[:item_to_move_to_id] }

          return create_error(
            'StoryItemNotFound',
            item_id: params[:item_id],
            story_id: params[:story_id]
          ) unless block_to_move_index.present?
          return create_error(
            'StoryItemNotFound',
            item_id: params[:item_to_move_to_id],
            story_id: params[:story_id]
          ) unless index_to_move_to.present?

          set_items = story.set_items.to_a
          updated_items = set_items.insert(index_to_move_to, set_items.delete_at(block_to_move_index))

          updated_items.each_with_index do |item, index|
            item.position = index + 1
          end

          updated_items.each(&:save!)

          create_response(status: 200, payload: updated_items.map(&::StoriesApi::V3::Presenters::StoryItem))
        end
      end
    end
  end
end
