module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Story do
        describe '#get' do
          it 'returns 404 if the Story is not found' do
            response = Story.new(id: 'foobar').get

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
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
        end

        describe '#delete' do
          it 'returns 404 if the Story is not found' do
            response = Story.new(id: 'foobar').delete

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
              }
            )
          end

          context 'succesful request' do
            let(:story) { create(:story) }
            let(:response) { Story.new(id: story.id).delete }

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
          let(:story) { create(:story) }
          let!(:response) { Story.new(id: story.id, story: patch).patch }
          let(:patch) do
            {
              description: 'foobar',
              tags: ['tags', 'go', 'here']
            }
          end

          it 'returns 404 if the Story is not found' do
            response = Story.new(id: 'foobar').patch

            expect(response).to eq(
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
              }
            )
          end

          context 'patch fails to validate' do
            let(:patch) { super().update(description: 123, tags: '') }

            it 'returns 400 with validation errors' do
              expect(response).to eq(
                status: 400,
                exception: {
                  message: 'Story patch failed to validate: description must be a string, tags must be an array'
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
              expect(updated_story.tags).to eq(patch[:tags])
            end
          end
        end
      end
    end
  end
end
