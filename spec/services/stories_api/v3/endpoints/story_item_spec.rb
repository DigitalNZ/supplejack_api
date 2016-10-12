# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      RSpec.describe StoryItem do
        before do
          @story = create(:story)
          @user = @story.user
        end

        describe '#initialize' do
          it 'should set user, story and a story item' do
            # passing id as a string as the id will be a string in the
            # request where as set_item.id is a BSON
            story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, api_key: @user.api_key)
            expect(story_item.user).to eq @user
            expect(story_item.story).to eq @story
            expect(story_item.item).to eq @story.set_items.first
          end

          context 'errors asfter initialize' do
            it 'should return UserNotFound error when user id dosent exist' do
              story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                         story_id: @story.id, api_key: 'fake')

              expect(story_item.errors).to eq(
                status: 404,
                exception: {
                  message: 'User with provided Api Key fake not found'
                }
              )
            end

            it 'should return StoryNotFound error when story id dosent exist' do
              story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                         story_id: 'fake', api_key: @user.api_key)

              expect(story_item.errors).to eq(
                status: 404,
                exception: {
                  message: 'Story with provided Id fake not found'
                }
              )              
            end

            it 'should return StoryItemNotFound error when story item id dosent exist' do
              story_item = StoryItem.new(id: 'fake',
                                         story_id: @story.id,
                                         api_key: @user.api_key)

              expect(story_item.errors).to eq(
                status: 404,
                exception: {
                  message: "StoryItem with provided Id fake not found for Story with provided Story Id #{@story.id}"
                }
              )
            end
          end
        end

        describe '#delete' do
          it 'should delete a set item from story' do
            item_to_delete = @story.set_items.first.id
            item_count = @story.set_items.count
            StoryItem.new(id: item_to_delete.to_s,
                          story_id: @story.id,
                          api_key: @user.api_key).delete

            @story.reload

            expect(@story.set_items.count).to be < item_count
            expect(@story.set_items.find_by_id(item_to_delete)).to be nil
          end

          it 'should return delete success code' do
            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                     story_id: @story.id,
                                     api_key: @user.api_key).delete

            expect(response).to eq(
              status: 204
            )
          end
        end

        describe '#patch' do
          it 'should fail with no content id error' do
            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, api_key: @user.api_key,
                                       item: { type: 'embed',
                                               sub_type: 'dnz',
                                               position: 1,
                                               content: {
                                                 title: 'Title New',
                                                 display_collection: 'New Marama',
                                                 category: 'New Te Papa',
                                                 image_url: 'New url',
                                                 tags: %w(foo bar)
                                               },
                                               meta: { school: 'foo'} }).patch

            expect(response).to eq(
              status: 400, exception: { message: 'Mandatory Parameters Missing: id is missing in content' }
            )
          end

          it 'should fail with content must be an intiger error' do
            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, api_key: @user.api_key,
                                       item: { type: 'embed',
                                               sub_type: 'dnz',
                                               position: 1,
                                               content: {
                                                 id: 'jhsdbgh',
                                                 title: 'Title New',
                                                 display_collection: 'New Marama',
                                                 category: 'New Te Papa',
                                                 image_url: 'New url',
                                                 tags: %w(foo bar)
                                               },
                                               meta: { school: 'foo'} }).patch

            expect(response).to eq(
              status: 400, exception: { message: 'Bad Request: id must be an integer in content' }
            )
          end

          it 'should update given set item' do
            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, api_key: @user.api_key,
                                       item: { type: 'embed',
                                               sub_type: 'dnz',
                                               position: 1,
                                               content: {
                                                 id: 100,
                                                 title: 'Title New',
                                                 display_collection: 'New Marama',
                                                 category: 'New Te Papa',
                                                 image_url: 'New url',
                                                 tags: %w(foo bar)
                                               },
                                               meta: { school: 'foo'} }).patch

            expect(response).to eq(
              {status: 200, 
               payload: { position: 1,
                          type: 'embed',
                          sub_type: 'dnz',
                          content: { 
                            value: 'foo',
                            id: 100,
                            title: 'Title New',
                            display_collection: 'New Marama',
                            category: 'New Te Papa',
                            image_url: 'New url',
                            tags: %w(foo bar)
                          },
                          meta: {
                            size: 1,
                            school: 'foo'
                            }
                          }
                          }
            )
          end
        end        
      end
    end
  end
end
