# module StoriesApi
#   module V3
#     module Presenters
#       RSpec.describe Story do
#         let(:story) do
#           story = create(:story)

#           story.set_items.first.position = 2
#           story.set_items.last.position = 1

#           story
#         end

#         context "called without any parameter or with slim equals false" do
#           let(:presented_json) {subject.call(story)}

#           it 'presents all top level fields' do
#             [:name, :description, :privacy, :copyright, :featured, :approved, :tags].each do |field|
#               expect(presented_json[field]).to eq(story.send(field))
#             end
#           end

#           it 'presents the id field as a string' do
#             expect(presented_json[:id]).to eq(story.id.to_s)
#           end

#           it 'presents the story creator' do
#             expect(presented_json[:creator]).to eq(story.user.name)
#           end

#           it 'presents number_of_items as the count of non-text the items in the UserSet' do
#             story.set_items.first.type = 'embed'
#             expect(presented_json[:number_of_items]).to eq 1
#           end

#           it 'presents the contents field as an array of valid StoryItems' do
#             expect(
#               presented_json[:contents].all? do |story_item|
#                 ::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(story_item)
#               end
#             ).to eq(true)
#           end

#           it 'presents the contents sorted by their position' do
#             positions = presented_json[:contents].map{|content| content[:position]}

#             expect(positions).to eq(positions.sort)
#           end

#           context "deleted cover image record" do
#             let(:set_item_1) { story.set_items.first }
#             let(:set_item_1_thumb) { 'https://deleted.example.com' }
#             let(:set_item_2) { story.set_items.last }
#             let(:set_item_2_thumb) { 'https://valid.example.com' }
#             let(:story) do
#               create(
#                 :story,
#                 cover_thumbnail: set_item_1_thumb,
#                 set_items: [
#                   create(:embed_dnz_item, title: 'last', position: 1, image_url: set_item_1_thumb),
#                   create(:embed_dnz_item, title: 'first', position: 2)
#                 ]
#               )
#             end

#             before(:each) do
#               set_item_1.record.fragments << build(:fragment, large_thumbnail_url: set_item_1_thumb)
#               set_item_2.record.fragments << build(:fragment, large_thumbnail_url: set_item_2_thumb)

#               set_item_1.record.reload.save! # Without this, source_ids validation fails ...
#               set_item_2.record.reload.save!
#             end

#             it "presents the meta is_cover on the non-deleted set item" do
#               expect(presented_json[:contents][0][:meta][:is_cover]).to eq true
#               expect(presented_json[:contents][1][:meta][:is_cover]).to eq false
#               expect(presented_json[:cover_thumbnail]).to eq set_item_1_thumb

#               set_item_1.record.update!(status: :deleted)
#               presented_json = subject.call(story.reload)

#               expect(presented_json[:contents][0][:meta][:is_cover]).to eq false
#               expect(presented_json[:contents][1][:meta][:is_cover]).to eq true
#               expect(presented_json[:cover_thumbnail]).to eq set_item_2_thumb
#             end
#           end

#         end

#         context "with slim paramter equals true" do
#           let(:presented_json) {subject.call(story, slim = true)}

#           it 'presents all top level fields' do
#             [:name, :description, :privacy, :copyright, :featured, :approved, :tags].each do |field|
#               expect(presented_json[field]).to eq(story.send(field))
#             end
#           end

#           it 'presents the id field as a string' do
#             expect(presented_json[:id]).to eq(story.id.to_s)
#           end

#           it 'presents non-text block number_of_items as the count of the items in the UserSet' do
#             story.set_items.first.type = 'embed'
#             expect(presented_json[:number_of_items]).to eq 1
#           end

#           it 'presents the contents field as nil' do
#             expect(presented_json[:contents]).to be_nil
#           end

#           it 'presents the record_ids sorted by their position' do
#             record_id_sorted = story.set_items.sort_by(&:position).map{ |x| x.record_id }
#             story_item_id_sorted = story.set_items.sort_by(&:position).map{ |x| x._id.to_s }
#             expect(presented_json[:record_ids].map{|item| item[:record_id] }).to eq(record_id_sorted)
#             expect(presented_json[:record_ids].map{|item| item[:story_item_id] }).to eq(story_item_id_sorted)
#           end

#           it 'stories with non text items presents the category of the story that is ticked as cover_thumb: true' do
#             story.set_items.build(attributes_for(:embed_dnz_item,meta: {is_cover: true}, category: ['Audio']))
#             story.save!

#             expect(presented_json[:category]).to eq 'Audio'
#           end

#           it 'stories with items that have no cover thumb, but have non-text items, presents the category as the first non-text item category' do
#             story.set_items.build(attributes_for(:embed_dnz_item,meta: {is_cover: false}, category: ['Books']))
#             story.save!

#             expect(presented_json[:category]).to eq 'Books'
#           end

#           it 'stories with only text items presents the category of the story as "other"' do
#             expect(presented_json[:category]).to eq 'Other'
#           end

#           it 'stories with no items presents the category of the story as "other"' do
#             story.set_items = []
#             story.save!

#             expect(presented_json[:category]).to eq 'Other'
#           end

#           it 'stories with a cover_thumbnail set item that has no category for some reason presents the category of the story as "other"' do
#             story.set_items.build(attributes_for(:embed_dnz_item, meta: {is_cover: true}, category: nil))
#             story.save!

#             expect(presented_json[:category]).to eq 'Other'
#           end
#         end
#       end
#     end
#   end
# end
