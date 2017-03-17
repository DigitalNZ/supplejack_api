module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Moves do
        describe '#post' do
          let(:story) { create(:story, number_of_story_items: 3) }
          let(:params) {{
            user_key: story.user.api_key,
            story_id: story.id.to_s,
            item_id: story.set_items.first.id.to_s,
            position: story.set_items.second.id.to_s,
          }}
          let(:response) {Moves.new(params).post}

          context 'invalid requests' do
            context 'malformed request' do
              [:story_id, :item_id, :position].each do |param|
                it "returns http 400 if #{param} is missing" do
                  params.delete(param)

                  expect(response[:status]).to eq(400)
                end
              end
            end
          end

          context 'valid request' do
            it 'moves the first story item to last' do
              params = {user_key: story.user.api_key,
                        story_id: story.id.to_s,
                        item_id: story.set_items.first.id.to_s,
                        position: story.set_items.last.position}

              response = Moves.new(params).post
              
              # Using array indexes to visually understand how the positions has changed
              expect(response[:status]).to eq(200)

              expect(response[:payload][0][:id]).to eq(story.set_items[1].id.to_s)
              expect(response[:payload][1][:id]).to eq(story.set_items[2].id.to_s)
              expect(response[:payload][2][:id]).to eq(story.set_items[0].id.to_s)
            end

            context 'requested data not found' do
              [:item_id, :story_id].each do |param|
                it "returns http 404 with error message if #{param} is not an existing block" do
                  params.merge!(param => 'a')

                  expect(response[:status]).to eq(404)
                  expect(response[:exception][:message]).to include(params[param])
                end
              end

              it 'returns 400 unsupported error if position is a string' do
                params.merge!(position: 'stringposition')

                expect(response[:status]).to eq(400)
                expect(response[:exception][:message]).to eq('Unsupported value stringposition for parameter position')
              end
            end

            context 'story belongs to another user' do
              let(:user) { create(:user) }
              let(:params) { super().merge(user_key: user.api_key) }

              it 'returns http 404' do
                expect(response[:status]).to eq(404)
              end
            end
          end
        end
      end
    end
  end
end
