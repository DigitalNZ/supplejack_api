module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Moves do
        describe '#post' do
          let(:story) { create(:story, number_of_story_items: 3) }
          let(:params) {{
            api_key: story.user.api_key,
            story_id: story.id.to_s,
            item_id: story.set_items.first.id.to_s,
            item_to_move_to_id: story.set_items.second.id.to_s,
          }}
          let(:response) {Moves.new(params).post}

          context 'malformed request' do
            [:story_id, :item_id, :item_to_move_to_id].each do |param|
              it "returns http 400 if #{param} is missing" do
                params.delete(param)

                expect(response[:status]).to eq(400)
              end
            end

          end

          context 'valid request' do
            context 'story belongs to current user' do
              it 'moves the block' do
                expect(response[:payload].first[:id]).to eq(story.set_items.second.id)
                expect(response[:payload].second[:id]).to eq(story.set_items.first.id)
              end

              [:item_id, :item_to_move_to_id].each do |param|
                it "returns http 404 with error message if #{param} is not an existing block" do
                  params.merge!(param => 'a')

                  expect(response[:status]).to eq(404)
                  expect(response[:exception][:message]).to include(params[param])
                end
              end

              it 'returns http 200' do
                expect(response[:status]).to eq(200)
              end
            end

            context 'story belongs to another user' do
              let(:user) { create(:user) }
              let(:params) { super().merge(api_key: user.api_key) }

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
