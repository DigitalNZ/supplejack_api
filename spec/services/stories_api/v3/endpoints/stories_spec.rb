# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Stories do
        describe '#new' do
          let(:user) { create(:user) }

          it 'initializes a user from the api_key passed' do
            stories = Stories.new(user_key: user.api_key)

            expect(stories.user).to eq user
          end
        end

        describe '#get' do
          it 'returns 404 if the provided user id does not exist' do
            response = Stories.new(user_key: '1231892312hj3k12j3').get

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Api Key 1231892312hj3k12j3 not found'
              }
            )
          end

          context 'successful request' do
            let(:response) { Stories.new(user_key: @user.api_key, slim: 'false').get }
            before do
              # So we have two users, because a story creates a user
              create(:story)
              @user = create(:story).user
              2.times {@user.user_sets.create(attributes_for(:story))}
            end

            it 'returns a 200 status code' do
              expect(response[:status]).to eq(200)
            end

            it 'returns an array of all of a users stories if the user exists' do
              payload = response[:payload]

              expect(payload.length).to eq(@user.user_sets.count)
              expect(payload.all?{|story| ::StoriesApi::V3::Schemas::Story.call(story).success?}).to eq(true)
            end
          end
        end

        describe '#post' do
          let(:user) { create(:user) }
          it 'returns 400 if the name field is missing for the Story' do
            params = ActionController::Parameters.new({story: '111', user_key: user.api_key})
            response = Stories.new(params).post

            expect(response).to eq(
              status: 400,
              exception: {
                message: 'Mandatory Parameter name missing in request'
              }
            )
          end

          context 'succesful request' do
            let(:params) { ActionController::Parameters.new({story: { name: 'Story Name' }, user_key: user.api_key}) }
            let!(:response) { Stories.new(params).post }

            before do
              user.reload
            end

            it 'creates a new Story for the current_user' do
              expect(user.user_sets.first.name).to eq('Story Name')
            end

            it 'returns the correct response shape' do
              expect(::StoriesApi::V3::Schemas::Story.call(response[:payload]).success?).to eq(true)
            end

            it 'uses a 200 status code' do
              expect(response[:status]).to eq(200)
            end
          end
        end
      end
    end
  end
end
