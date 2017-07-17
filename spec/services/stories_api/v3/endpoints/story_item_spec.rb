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
                                       story_id: @story.id, user_key: @user.api_key)
            expect(story_item.user).to eq @user
            expect(story_item.story).to eq @story
            expect(story_item.item).to eq @story.set_items.first
          end

          context '#find_user' do
            it 'should find a user by api key' do
              story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                         story_id: @story.id, user_key: @user.api_key)

              expect(SupplejackApi::User).to receive(:find_by_api_key).with(@user.api_key)
              story_item.find_user
            end
          end

          context '#find_story' do
            it 'should find a story by id' do
              story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                         story_id: @story.id, user_key: @user.api_key)

              expect(story_item.find_story).to eq @story
            end
          end

          context '#find_item' do
            it 'should find a set item by id' do
              story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                         story_id: @story.id, user_key: @user.api_key)

              expect(story_item.find_item).to eq(@story.set_items.first)
            end
          end

          context 'errors asfter initialize' do
            it 'should return UserNotFound error when user id dosent exist' do
              story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                         story_id: @story.id, user_key: 'fake')

              expect(story_item.errors).to eq(
                status: 404,
                exception: {
                  message: 'User with provided Api Key fake not found'
                }
              )
            end

            it 'should return StoryNotFound error when story id dosent exist' do
              story_item = StoryItem.new(id: @story.set_items.first.id.to_s,
                                         story_id: 'fake', user_key: @user.api_key)

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
                                         user_key: @user.api_key)

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
          it 'deletes a set item from story' do
            item_to_delete = @story.set_items.first.id
            item_count = @story.set_items.count
            StoryItem.new(id: item_to_delete.to_s,
                          story_id: @story.id,
                          user_key: @user.api_key).delete

            @story.reload

            expect(@story.set_items.count).to be < item_count
            expect(@story.set_items.find_by_id(item_to_delete)).to be nil
          end

          it 'returns 404 when story dosent exist' do
            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                     story_id: 'madeupkey',
                                     user_key: @user.api_key).delete

            expect(response).to eq(
              :status=>404, :exception=>{:message=>"Story with provided Id madeupkey not found"}
            )
          end

          it 'returns 204 delete success code' do
            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                     story_id: @story.id,
                                     user_key: @user.api_key).delete

            expect(response).to eq(
              status: 204
            )
          end

          it 'updates the story cover_thumbanil as nil if the item has same image_url' do
            expect(@story.cover_thumbnail).to be_truthy # ie not nil

            @story.update_attribute(:cover_thumbnail, @story.set_items.first.content[:image_url])
            StoryItem.new(id: @story.set_items.first.id.to_s, story_id: @story.id, user_key: @user.api_key).delete
            @story.reload

            expect(@story.cover_thumbnail).to be_nil
          end
        end

        describe '#patch' do
          it 'fails with no content id error' do
            item = create(:story_item, type: 'embed', sub_type: 'record', position: 1,
                          content: { title: 'Title', display_collection: 'Marama', value: 'bar',
                                     category: ['Te Papa'], image_url: 'url', tags: %w(foo bar)},
                          meta: { size: 1, metadata: 'Some Meta' }).attributes.symbolize_keys
            item.delete(:_id)

            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, user_key: @user.api_key,
                                       item: item).patch

            expect(response).to eq(
              status: 400, exception: { message: 'Mandatory Parameters Missing: id is missing in content' }
            )
          end

          it 'fails with content must be an intiger error' do
            item = create(:story_item, type: 'embed', sub_type: 'record', position: 1,
                          content: { id: "zfkjg"},
                          meta: { size: 1, metadata: 'Some Meta' }).attributes.symbolize_keys
            item.delete(:_id)

            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, user_key: @user.api_key,
                                       item: item).patch

            expect(response).to eq(
              status: 400, exception: { message: 'Bad Request: id must be an integer in content' }
            )
          end

          it 'updates given set item' do
            record = create(:record)
            item = create(:story_item, type: 'embed', sub_type: 'record', position: 1,
                          content: { id: record.record_id},
                          meta: { size: 1, metadata: 'Some Meta' }).attributes.symbolize_keys
            item.delete(:_id)

            response = StoryItem.new(id: @story.set_items.first.id.to_s,
                                       story_id: @story.id, user_key: @user.api_key,
                                       item: item).patch

            result = response[:payload]
            result.delete(:id)

            expect(result[:meta]).to eq(item[:meta])
          end

          context 'setting cover thumbnail' do
            let(:record) { create(:record) }

            it 'updates cover thumbnail of story if meta is_cover true' do
              item = create(:story_item, type: 'embed', sub_type: 'record', position: 1,
                            content: { id: record.record_id},
                            meta: { size: 1, metadata: 'Some Meta', is_cover: true}).attributes.symbolize_keys

              StoryItem.new(id: @story.set_items.first.id.to_s,
                            story_id: @story.id, user_key: @user.api_key,
                            item: item).patch

              @story.reload

              expect(@story.cover_thumbnail).to eq @story.set_items.first.content[:image_url].to_s
            end

            it 'updates cover thumbnail of story as nil if meta is_cover false' do
              item = create(:story_item, type: 'embed', sub_type: 'record', position: 1,
                            content: { id: record.record_id},
                            meta: { size: 1, metadata: 'Some Meta', is_cover: false}).attributes.symbolize_keys
              @story.update_attribute(:cover_thumbnail, @story.set_items.first.content[:image_url])

              StoryItem.new(id: @story.set_items.first.id.to_s,
                            story_id: @story.id, user_key: @user.api_key,
                            item: item).patch

              @story.reload

              expect(@story.cover_thumbnail).to be_nil
            end
          end
        end
      end
    end
  end
end
