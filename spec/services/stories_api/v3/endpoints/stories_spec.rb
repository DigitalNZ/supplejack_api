module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Stories do
        describe '#get' do
          it 'returns 404 if the provided user id does not exist' do
            response = Stories.new(user: '1231892312hj3k12j3').get

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'User with provided Id not found'
              }
            )
          end

          context 'successful request', focus: true do
            let(:response) { Stories.new(user: @user.api_key).get }
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
      end
    end
  end
end
