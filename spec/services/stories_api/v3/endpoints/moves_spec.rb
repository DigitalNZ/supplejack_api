module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Moves do
        describe '#post' do
          let(:story) { create(:story) }
          let(:params) {{api_key: story.user.api_key, story_id: story.id.to_s, item_id: story.set_items.first.id.to_s, position: '2'}}
          let(:response) {Moves.new(params).post}

          context 'malformed request' do
            [:story_id, :item_id, :position].each do |param|
              it "returns http 400 if #{param} is missing" do
                params.delete(param)

                expect(response[:status]).to eq(400)
              end
            end

            it 'returns http 400 with error message if position is not an integer' do
              params.merge!(position: 'a')

              expect(response[:status]).to eq(400)
              expect(response[:exception][:message]).to include('Unsupported value')
            end
          end

          context 'valid request' do
            context 'story belongs to current user' do
              it 'moves the block' do
                expect(response[:payload].first[:id]).to eq(story.set_items.last.id)
                expect(response[:payload].last[:id]).to eq(story.set_items.first.id)
              end

              it 'returns http 404 if story item is not found' do
                params.merge!(item_id: 'foo')

                expect(response[:status]).to eq(404)
              end

              it 'handles integer positions' do
                params.merge!(position: 2)

                expect(response[:status]).to eq(200)
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
