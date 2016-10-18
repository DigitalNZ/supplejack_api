module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Moves do
        describe '#post' do
          context 'valid request' do
            let(:story) { create(:story) }
            let(:params) {{api_key: story.user.api_key, story_id: story.id, story_item_id: story.set_items.first.id, position: '2'}}
            let(:response) {Moves.new(params).post}

            it 'moves the block' do
              expect(response[:payload].first[:id]).to eq(story.set_items.last.id)
              expect(response[:payload].last[:id]).to eq(story.set_items.first.id)
            end
          end
        end
      end
    end
  end
end
