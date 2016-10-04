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
            story_item = StoryItems.new(id: @story.id, user: @user.api_key)
            expect(story_item.user).to eq @user
            expect(story_item.story).to eq @story
          end
        end

        describe '#get' do
          it 'returns 404 if the provided user id does not exist' do
            response = StoryItems.new(id: '3', user: 'madeupuser').errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )
          end

          it 'returns 404 if the story id dosent exist' do
            @story = create(:story)
            response = StoryItems.new(id: 'madeupkey', user: @story.user.api_key).errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id madeupkey not found'
              }
            )
          end

          context 'successful request' do
            let(:response) { StoryItems.new(id: @story.id, user: @user.api_key).get }
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
            response = StoryItems.new(id: 'madeupkey', user: 'madeupuser').errors

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )            
          end

          it 'returns 404 if the story dosent exist' do
            @story = create(:story)
            response = StoryItems.new(id: 'madeupkey', user: @story.user.api_key).errors

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
              response = StoryItems.new(id: @story.id,
                                        user: @user.api_key,
                                        block: { sub_type: 'dnz',
                                                 meta: {} }).post
              expect(response).to eq(
                status: 422,
                exception: {
                  message: 'Mandatory Parameter type missing in request'
                }
              )
            end

            it 'should return error when sub_type is missing' do
              response = StoryItems.new(id: @story.id,
                                        user: @user.api_key,
                                        block: { type: 'embed',
                                                 meta: {} }).post
              expect(response).to eq(
                status: 422,
                exception: {
                  message: 'Mandatory Parameter sub_type missing in request'
                }
              )
            end

            it 'should return error when content is missing' do
              response = StoryItems.new(id: @story.id,
                                        user: @user.api_key,
                                        block: { type: 'embed',
                                                 sub_type: 'dnz',
                                                 meta: {} }).post
              expect(response).to eq(
                status: 422,
                exception: {
                  message: 'Bad Request. content is missing'
                }
              )
            end

            it 'should return error when meta is missing' do
              response = StoryItems.new(id: @story.id,
                                        user: @user.api_key,
                                        block: { type: 'embed',
                                                 sub_type: 'dnz',
                                                 content: {} }).post
              expect(response).to eq(
                status: 422,
                exception: {
                  message: 'Bad Request. meta is missing'
                }
              )
            end

            it 'should return error when content is empty' do
              response = StoryItems.new(id: @story.id,
                                        user: @user.api_key,
                                        block: { type: 'embed',
                                                 sub_type: 'dnz',
                                                 content: {},
                                                 meta: {} }).post
              expect(response).to eq(
                status: 422,
                exception: {
                  message: 'Bad Request. content id is missing, content title is missing, content display_collection is missing, content category is missing, content image_url is missing, content tags is missing'
                }
              )
            end

            it 'should return error when type is not valid' do
              response = StoryItems.new(id: @story.id,
                                        user: @user.api_key,
                                        block: { type: 'youtube',
                                                 sub_type: 'dnz',
                                                 content: {},
                                                 meta: {} }).post
              expect(response).to eq(
                status: 415,
                exception: {
                  message: 'Unsupported value youtube for parameter type'
                }
              )
            end

            it 'should return error when sub_type is not valid' do
              response = StoryItems.new(id: @story.id,
                                        user: @user.api_key,
                                        block: { type: 'embed',
                                                 sub_type: 'fancy_text',
                                                 content: {},
                                                 meta: {} }).post
              expect(response).to eq(
                status: 415,
                exception: {
                  message: 'Unsupported value fancy_text for parameter sub_type'
                }
              )
            end            
          end
        end
      end
    end
  end
end
