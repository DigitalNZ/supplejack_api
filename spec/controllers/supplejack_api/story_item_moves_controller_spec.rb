# module SupplejackApi
#   RSpec.describe StoryItemMovesController do
#     routes { SupplejackApi::Engine.routes }

#     describe 'POST #create' do
#       context 'valid request' do
#         let(:story) do
#           create(
#             :story,
#             set_items: [
#               create(:embed_dnz_item, title: 'last', position: 1),
#               create(:embed_dnz_item, title: 'first', position: 2),
#               create(:embed_dnz_item, title: 'middle', position: 3)
#             ]
#           )
#         end

#         let(:ordered_items) { story.set_items.sort_by(&:position) }
#         let(:first_title) { ordered_items.first.content[:title] }
#         let(:last_title) { ordered_items.last.content[:title] }

#         before do
#           post :create, params: {story_id: story.id, item_id: story.set_items.first.id, position: story.set_items.last.id, api_key: story.user.api_key, user_key: story.user.api_key}
#         end

#         it 'moves the block' do
#           story.reload

#           expect(first_title).to eq('first')
#           expect(last_title).to eq('last')
#         end

#         it 'returns a 200 code' do
#           expect(response.status).to eq(200)
#         end
#       end
#     end
#   end
# end
