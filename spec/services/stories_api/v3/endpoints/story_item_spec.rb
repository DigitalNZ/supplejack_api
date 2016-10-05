# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      RSpec.describe StoryItem do
        describe '#initialize' do
          before do
            @story = create(:story)
            @user = @story.user
          end

          it 'should set user, story and a story item' do
            # passing id as a string as the id will be a string in the
            # request where as set_item.id is a BSON
            story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, user: @user.api_key)
            expect(story_item.user).to eq @user
            expect(story_item.story).to eq @story
            expect(story_item.item).to eq @story.set_items.first
          end
        end
      end
    end
  end
end
