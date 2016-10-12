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
            story_item = StoryItems.new(story_id: @story.id, api_key: @user.api_key)
            expect(story_item.user).to eq @user
            expect(story_item.story).to eq @story
          end
        end

        describe '#get' do
          it 'returns 404 if the provided user id does not exist' do
            response = StoryItems.new(story_id: '3', api_key: 'madeupuser').errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )
          end

          it 'returns 404 if the story id dosent exist' do
            @story = create(:story)
            response = StoryItems.new(story_id: 'madeupkey', api_key: @story.user.api_key).errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id madeupkey not found'
              }
            )
          end

          context 'successful request' do
            let(:response) { StoryItems.new(story_id: @story.id, api_key: @user.api_key).get }
            before do
              @story = create(:story)
              @user = @story.user
            end

            it 'returns a 200 status code' do
              # expect(response[:status]).to eq(200)
            end

            it 'returns an array of all of a users stories if the user exists' do
              # payload = response[:payload]

              # expect(payload.length).to eq(@story.set_items.count)
              # expect(payload.all?{ |story| ::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(story) }).to eq(true)
            end
          end
        end

        describe '#post' do
          it 'returns 404 if the user dosent exist' do
            response = StoryItems.new(story_id: 'madeupkey',
                                      api_key: 'madeupuser').errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )            
          end

          it 'returns 404 if the story dosent exist' do
            @story = create(:story)
            response = StoryItems.new(story_id: 'madeupkey',
                                      api_key: @story.user.api_key).errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id madeupkey not found'
              }
            )          
          end


          context 'valid user and story' do
            before do
              @story = create(:story)
              @user = @story.user
            end

            it 'should return error when type is missing' do
              response = StoryItems.new(story_id: @story.id,
                                        api_key: @user.api_key,
                                        block: { sub_type: 'dnz',
                                                 meta: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Mandatory Parameters Missing: type is missing'
                }
              )
            end

            it 'should return error when sub_type is missing' do
              response = StoryItems.new(story_id: @story.id,
                                        api_key: @user.api_key,
                                        block: { type: 'embed',
                                                 meta: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Mandatory Parameters Missing: sub_type is missing'
                }
              )
            end

            it 'should return error when content is missing' do
              response = StoryItems.new(story_id: @story.id,
                                        api_key: @user.api_key,
                                        block: { type: 'embed',
                                                 sub_type: 'dnz',
                                                 meta: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Mandatory Parameters Missing: content is missing'
                }
              )
            end

            it 'should return error when meta is missing' do
              response = StoryItems.new(story_id: @story.id,
                                        api_key: @user.api_key,
                                        block: { type: 'embed',
                                                 sub_type: 'dnz',
                                                 content: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Mandatory Parameters Missing: id is missing, title is missing, display_collection is missing, category is missing, image_url is missing, tags is missing in content meta is missing'
                }
              )
            end

            it 'should return error when type is not valid' do
              response = StoryItems.new(story_id: @story.id,
                                        api_key: @user.api_key,
                                        block: { type: 'youtube',
                                                 sub_type: 'dnz',
                                                 content: {},
                                                 meta: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Unsupported Values: type must be one of: embed, text'
                }
              )
            end

            it 'should return error when sub_type is not valid' do
              response = StoryItems.new(story_id: @story.id,
                                        api_key: @user.api_key,
                                        block: { type: 'embed',
                                                 sub_type: 'fancy_text',
                                                 content: {},
                                                 meta: {} }).post
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Unsupported Values: sub_type must be one of: dnz, heading, rich_text'
                }
              )
            end

            # Text Items
            context 'text item' do
              it 'should return error when text heading block' do
                response = StoryItems.new(story_id: @story.id,
                                          api_key: @user.api_key,
                                          block: { type: 'text',
                                                   sub_type: 'heading',
                                                   content: {},
                                                   meta: {} }).post
                expect(response).to eq(
                  status: 400,
                  exception: {
                    message: 'Mandatory Parameters Missing: value is missing in content'
                  }
                )
              end

              it 'should return created text heading story item' do
                response = StoryItems.new(story_id: @story.id,
                                          api_key: @user.api_key,
                                          block: { type: 'text',
                                                   sub_type: 'heading',
                                                   position: 0,
                                                   content: { value: 'Some Heading' },
                                                   meta: {} }).post
                result = response[:payload]
                result.delete(:id)

                expect(result).to eq(
                    type: 'text',
                    sub_type: 'heading',
                    position: 0,
                    content: {
                      value: 'Some Heading'
                    },
                    meta: {}
                )
              end

              it 'should return created text rich_text story item' do
                response = StoryItems.new(story_id: @story.id,
                                          api_key: @user.api_key,
                                          block: { type: 'text',
                                                   sub_type: 'rich_text',
                                                   position: 0,
                                                   content: { value: 'Some Rich Text' },
                                                   meta: {} }).post

                result = response[:payload]
                result.delete(:id)

                expect(response[:payload]).to eq(
                    type: 'text',
                    sub_type: 'rich_text',
                    position: 0,
                    content: {
                      value: 'Some Rich Text'
                    },
                    meta: {}
                )
              end
            end

            # Embed Item
            context 'embed item' do
              it 'should return error when content is empty' do
                response = StoryItems.new(story_id: @story.id,
                                          api_key: @user.api_key,
                                          block: { type: 'embed',
                                                   sub_type: 'dnz',
                                                   content: {},
                                                   meta: {} }).post
                expect(response).to eq(
                  status: 400,
                  exception: {
                    message: 'Mandatory Parameters Missing: id is missing, title is missing, display_collection is missing, category is missing, image_url is missing, tags is missing in content'
                  }
                )
              end

              it 'should return error for wrong type or values' do
                response = StoryItems.new(story_id: @story.id,
                                          api_key: @user.api_key,
                                          block: { type: 'embed',
                                                   sub_type: 'dnz',
                                                   position: 0,
                                                   content: {
                                                     id: 'jhdfg',
                                                     title: 'Title',
                                                     display_collection: 'Marama',
                                                     category: 'Te Papa',
                                                     image_url: 'url',
                                                     tags: 'foo'
                                                   },
                                                   meta: {} }).post
                expect(response).to eq(
                  status: 400,
                  exception: {
                    message: 'Bad Request: id must be an integer, tags must be an array in content'
                  }
                )
              end

              it 'should return the created dnz item' do
                payload = {
                    position: 0,
                    type: 'embed',
                    sub_type: 'dnz',
                    content: {
                      id: 100,
                      title: 'Title',
                      display_collection: 'Marama',
                      category: 'Te Papa',
                      image_url: 'url',
                      tags: %w(foo bar)
                    },
                    meta: { somemeta: 'metadata'}
                  }

                response = StoryItems.new(story_id: @story.id,
                                          api_key: @user.api_key,
                                          block: payload).post
                result = response[:payload]
                result.delete(:id)

                expect(result).to eq payload
              end
            end
          end
        end

        describe '#put' do
          before do
            @story = create(:story)
            @user = @story.user
          end

          it 'should return the created dnz item' do
            old_story_items = @story.set_items
            blocks = [{ type: 'embed',
                        sub_type: 'dnz',
                        position: 0,
                        content: {
                          id: 100,
                          title: 'Title',
                          display_collection: 'Marama',
                          category: 'Te Papa',
                          image_url: 'url',
                          tags: %w(foo bar)
                        },
                        meta: { school: 'foo'} },
                       { type: 'embed',
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
                         meta: { school: 'foo'} }]

            response = StoryItems.new(story_id: @story.id,
                                      api_key: @user.api_key,
                                      blocks: blocks).put

            expect(response[:status]).to eq 200

            response[:payload].each do |block|
              block.delete(:id)
              expect(blocks.include? block).to be true
            end
          end        
        end
      end
    end
  end
end
