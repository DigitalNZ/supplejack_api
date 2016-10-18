# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class Moves
        include Helpers

        attr_reader :story_item_id, :position

        def initialize(params)
          @story_id = params[:story_id]
          @story_item_id = params[:story_item_id]
          @position = params[:position].to_i
        end

        def post
          story = SupplejackApi::UserSet.find_by(id: @story_id)
          block_to_move_index = story.set_items.find_index { |x| x.id == @story_item_id }

          set_items = story.set_items.to_a
          updated_items = set_items.insert(position - 1, set_items.delete_at(block_to_move_index))

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
