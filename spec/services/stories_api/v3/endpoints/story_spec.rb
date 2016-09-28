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

          context 'succesful request' do
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
      end
    end
  end
end
