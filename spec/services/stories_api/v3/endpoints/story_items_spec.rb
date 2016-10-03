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
            response = StoryItems.new(id: '3', user: 'madeupuser').get

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )
          end

          it 'returns 404 if the story id dosent exist' do
            @story = create(:story)
            response = StoryItems.new(id: 'madeupkey', user: @story.user.api_key).get

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
            response = StoryItems.new(id: 'madeupkey', user: 'madeupuser').post

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key madeupuser not found'
              }
            )            
          end

          it 'returns 404 if the story dosent exist' do
            @story = create(:story)
            response = StoryItems.new(id: 'madeupkey', user: @story.user.api_key).post

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

            it 'should return error when story item params are not valid' do
              response = StoryItems.new(id: @story.id, user: @user.api_key).post

            end
          end
        end
      end
    end
  end
end
