# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      RSpec.describe StoryItems do
        describe '#initialize' do
          before do
            @story = create(:story)
            @user = @story.user
          end

          it 'should set user and story' do
            story_item = StoryItems.new(story_id: @story.id, user_key: @user.api_key)
            expect(story_item.user).to eq @user
            expect(story_item.story).to eq @story
          end
        end

        describe '#get' do
          it 'returns 404 if the provided user id does not exist' do
            response = StoryItems.new(story_id: '3', user_key: 'madeupuser').errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )
          end

          it 'returns 404 if the story id dosent exist' do
            @story = create(:story)
            response = StoryItems.new(story_id: 'madeupkey', user_key: @story.user.api_key).errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id madeupkey not found'
              }
            )
          end

          context 'successful request' do
            let(:response) { StoryItems.new(story_id: @story.id, user_key: @user.api_key).get }
            before do
              @story = create(:story)
              @user = @story.user
            end

            it 'returns a 200 status code' do
              expect(response[:status]).to eq(200)
            end

            it 'returns an array of all of a users stories if the user exists' do
              payload = response[:payload]

              expect(payload.length).to eq(@story.set_items.count)
              expect(payload.all?{ |story| ::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(story) }).to eq(true)
            end
          end
        end

        describe '#post' do
          it 'returns 404 if the user dosent exist' do
            response = StoryItems.new(story_id: 'madeupkey', user_key: 'madeupuser').errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )            
          end

          it 'returns 404 if the story dosent exist' do
            @story = create(:story)
            response = StoryItems.new(story_id: 'madeupkey', user_key: @story.user.api_key).errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id madeupkey not found'
              }
            )          
          end

          context 'when position passed on create item' do
            before do
              record = create(:record)
              @story = create(:story)
              @user = @story.user
              @item = create(:story_item, type: 'embed', sub_type: 'dnz', 
                             position: 1, # This value is the index for the array of set items. ie position 2
                             content: { id: record.record_id }, meta: {}).attributes.symbolize_keys
              
              @item.delete(:_id)
            end

            it 'calls the moves service' do
              expect_any_instance_of(StoriesApi::V3::Endpoints::Moves).to receive(:post)

              StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                             item: @item).post
            end

            it 'creates a new set item with the provided position' do
              response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                        item: @item).post
            
              expect(response[:status]).to eq 200
              expect(response[:payload][:position]).to eq 2
            end

            it 'updates positions of each story set item' do
              response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                        item: @item).post

              @story.reload

              expect(@story.set_items.last.position).to eq 2
            end
          end

          context 'valid user and story' do
            before do
              @story = create(:story)
              @user = @story.user
            end

            it 'should return error when type is missing' do
              response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                        item: { sub_type: 'dnz', meta: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Mandatory Parameters Missing: type is missing'
                }
              )
            end

            it 'should return error when sub_type is missing' do
              response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                        item: { type: 'embed', meta: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Mandatory Parameters Missing: sub_type is missing'
                }
              )
            end

            it 'should return error when content is missing' do
              response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                        item: { type: 'embed', sub_type: 'dnz', meta: {} }).post

              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Mandatory Parameters Missing: content is missing'
                }
              )
            end

            it 'should return error when type is not valid' do
              item = create(:story_item, type: 'youtube', sub_type: 'dnz', content: {}, meta: {}).attributes.symbolize_keys
              item.delete(:_id)

              response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                        item: item).post

              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Unsupported Values: type must be one of: embed, text'
                }
              )
            end

            it 'should return error when sub_type is not valid' do
              item = create(:story_item, type: 'embed', sub_type: 'fancy_text', content: {}, meta: {}).attributes.symbolize_keys
              item.delete(:_id)

              response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                        item: item).post

              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Unsupported Values: sub_type must be one of: dnz, heading, rich-text'
                }
              )
            end

            # Text Items
            context 'text item' do
              before do
                @factory = create(:story_item, type: 'text', sub_type: 'rich-text',
                                             content: { value: 'Some Text' },
                                             meta: { metadata: 'Some Meta' })
                @item = @factory.attributes.symbolize_keys
                @item.delete(:_id)
              end

              it 'should return error when text heading block' do
                item = @item
                item[:content].delete(:value)

                response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                          item: item).post

                expect(response).to eq(
                  status: 400,
                  exception: {
                    message: 'Mandatory Parameters Missing: value is missing in content'
                  }
                )
              end

              it 'should return created text rich-text story item' do
                response = StoryItems.new(story_id: @story.id, user_key: @user.api_key,
                                          item: @item).post

                result = response[:payload]
                result.delete(:id)
                result.delete(:record_id) 
                expect(result).to eq ({ position: 3, type: "text", 
                                        sub_type: "rich-text", content: { value: "Some Text" },
                                        meta: { metadata: "Some Meta"}})
              end
            end

            # Embed Item
            context 'embed item' do
              before do
                record = create(:record)
                factory = create(:story_item, type: 'embed', sub_type: 'dnz',
                                             content: { id: record.record_id},
                                             meta: { metadata: 'Some Meta' })

                @item = factory.attributes.symbolize_keys
                @item.delete(:_id)
                @item.delete(:id)
              end

              it 'should return error when content is empty' do
                item = @item
                item[:content].delete(:id)

                response = StoryItems.new(story_id: @story.id,
                                          user_key: @user.api_key,
                                          item: item).post
                expect(response).to eq(
                  status: 400,
                  exception: {
                    message: 'Mandatory Parameters Missing: id is missing in content'
                  }
                )
              end

              it 'should return error for wrong type or values' do
                item = @item
                item[:content][:id] = 'zfbgksdgjb'

                response = StoryItems.new(story_id: @story.id,
                                          user_key: @user.api_key,
                                          item: item).post
                expect(response).to eq(
                  status: 400,
                  exception: {
                    message: 'Bad Request: id must be an integer in content'
                  }
                )
              end

              it 'should return the created dnz item' do
                response = StoryItems.new(story_id: @story.id,
                                          user_key: @user.api_key,
                                          item: @item).post
                result = response[:payload]
                result.delete(:id)

                expect(result[:content][:id]).to eq @item[:content][:id]
              end
            end

            context 'setting cover thumbnail' do
              let(:record) { create(:record_with_fragment) }

              it 'updates the cover thumbnail if it dosent exist' do
                @story.update_attribute(:cover_thumbnail, nil)
                factory = create(:story_item, type: 'embed', sub_type: 'dnz',
                             content: { id: record.record_id},
                             meta: { metadata: 'Some Meta' })

                item = factory.attributes.symbolize_keys

                expect(@story.cover_thumbnail).to be_nil

                StoryItems.new(story_id: @story.id,
                               user_key: @user.api_key,
                               item: item).post

                @story.reload

                expect(@story.cover_thumbnail).to eq record.large_thumbnail_url
              end
            end
          end
        end
      end
    end
  end
end
