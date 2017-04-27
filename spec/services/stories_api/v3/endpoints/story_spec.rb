module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Story do
        before { @user = FactoryGirl.create(:user, authentication_token: 'apikey', role: 'developer') }

        describe '#new' do
          it 'initializes a supplejack user' do
            story = Story.new(id: 'foobar', user_key: @user.authentication_token)
            
            expect(story.user).to eq @user
          end
        end

        describe '#get' do
          it 'returns 404 if the Story is not found' do
            response = Story.new(id: 'foobar', user_key: @user.authentication_token).get

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id foobar not found'
              }
            )
          end

          context 'successful request' do
            let(:story) { create(:story) }
            let(:response) { Story.new(id: story.id).get }

            it 'returns a 200 status code' do
              expect(response[:status]).to eq(200)
            end

            it 'returns a valid Story shape' do
              expect(::StoriesApi::V3::Schemas::Story.call(response[:payload]).success?).to eq(true)
            end
          end

          context 'when story is private' do
            let(:developer_restriction) { double(:developer_restriction, admin: false) }
            let(:admin_restriction) { double(:admin_restriction, admin: true) }
            let(:story_user) { create(:user, authentication_token: 'story_user_key', role: 'developer') }
            let(:admin_user) { create(:user, authentication_token: 'admin_key', role: 'admin') }
            let(:story) { create(:story, user: story_user, privacy: 'private') }


            # RecordSchema is suppose to return the roles and confirm .admin? method
            # So RecordSchema has to be stubed for this test
            it 'returns error if the story dosent belong to the user' do
              allow(RecordSchema).to receive(:roles) { {developer: developer_restriction} }
              response = Story.new(id: story.id, user_key: @user.api_key).get

              expect(response[:status]).to eq 401
              expect(response[:exception][:message]).to eq "Story with provided Id #{story.id} is private story and requires the creator's key as user_key"
            end

            it 'returns the story successfuly if the story belongs to the user' do
              allow(RecordSchema).to receive(:roles) { {developer: developer_restriction} }
              response = Story.new(id: story.id, user_key: story_user.api_key).get

              expect(response[:status]).to eq 200
              expect(response[:payload][:id]).to eq story.id.to_s
            end

            it 'returns the story successfuly if the user is an admin and story dosent belong to user' do
              allow(RecordSchema).to receive(:roles) { {admin: admin_restriction} }
              response = Story.new(id: story.id, user_key: admin_user.api_key).get

              expect(response[:status]).to eq 200
              expect(response[:payload][:id]).to eq story.id.to_s
            end
          end
        end

        describe '#delete' do
          it 'returns 404 if the Story is not found' do
            response = Story.new(id: 'foobar', user_key: @user.authentication_token).delete

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id foobar not found'
              }
            )
          end

          context 'succesful request' do
            let(:story) { create(:story, user: @user) }
            let(:response) { Story.new(id: story.id, user_key: @user.authentication_token).delete }

            it 'returns a 204 status code' do
              expect(response[:status]).to eq(204)
            end

            it 'deletes the Story with the provided id' do
              expect(SupplejackApi::UserSet.count).to eq(0)

              # 'touch' Story to create it
              story
              expect(SupplejackApi::UserSet.count).to eq(1)

              # 'touch' API method to delete it
              response
              expect(SupplejackApi::UserSet.count).to eq(0)
            end
          end
        end

        describe '#patch' do
          let(:story) { create(:story, user: @user) }
          let!(:response) { Story.new(id: story.id, story: patch, user_key: @user.authentication_token).patch }
          let(:patch) do
            {
              description: 'foobar',
              subjects: ['tags', 'go', 'here']
            }
          end

          it 'returns 404 if the Story is not found' do
            response = Story.new(id: 'foobar', user_key: @user.authentication_token).patch

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with provided Id foobar not found'
              }
            )
          end

          context 'patch fails to validate' do
            let(:patch) { super().update(description: 123, tags: '') }

            it 'returns 400 with validation errors' do
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Bad Request: description must be a string tags must be an array'
                }
              )
            end
          end

          context 'successful request' do
            it 'returns a 200 status code' do
              expect(response[:status]).to eq(200)
            end

            it 'returns a valid Story shape' do
              expect(::StoriesApi::V3::Schemas::Story.call(response[:payload]).success?).to eq(true)
            end

            it 'returns the updated Story' do
              expect(response[:payload][:description]).to eq(patch[:description])
            end

            it 'updates the Story in the database with the new fields' do
              updated_story = SupplejackApi::UserSet.custom_find(story.id)

              expect(updated_story.description).to eq(patch[:description])
              expect(updated_story.subjects).to eq(patch[:subjects])
            end
          end
        end
      end
    end
  end
end
