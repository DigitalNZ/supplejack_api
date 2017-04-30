module StoriesApi
  module V3
    module Presenters
      RSpec.describe Story do
        let(:story) do
          story = create(:story)

          story.set_items.first.position = 2
          story.set_items.last.position = 1

          story
        end

        context "called without any parameter or with slim equals false" do
          let(:presented_json) {subject.call(story)}

          it 'presents all top level fields' do
            [:name, :description, :privacy, :copyright, :featured, :approved, :tags].each do |field|
              expect(presented_json[field]).to eq(story.send(field))
            end
          end

          it 'presents the id field as a string' do
            expect(presented_json[:id]).to eq(story.id.to_s)
          end

          it 'presents the story creator' do
            expect(presented_json[:creator]).to eq(story.user.name)
          end

          it 'presents number_of_items as the count of the items in the UserSet' do
            expect(presented_json[:number_of_items]).to eq(story.set_items.count)
          end

          it 'presents the contents field as an array of valid StoryItems' do
            expect(
              presented_json[:contents].all? do |story_item|
                ::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(story_item)
              end
            ).to eq(true)
          end

          it 'presents the contents sorted by their position' do
            positions = presented_json[:contents].map{|content| content[:position]}

            expect(positions).to eq(positions.sort)
          end
        end

        context "with slim paramter equals true" do
          let(:presented_json) {subject.call(story, slim = true)}

          it 'presents all top level fields' do
            [:name, :description, :privacy, :copyright, :featured, :approved, :tags].each do |field|
              expect(presented_json[field]).to eq(story.send(field))
            end
          end

          it 'presents the id field as a string' do
            expect(presented_json[:id]).to eq(story.id.to_s)
          end

          it 'presents number_of_items as the count of the items in the UserSet' do
            expect(presented_json[:number_of_items]).to eq(story.set_items.count)
          end

          it 'presents the contents field as nil' do
            expect(presented_json[:contents]).to be_nil
          end

          it 'presents the record_ids sorted by their position' do
            record_id_sorted = story.set_items.sort_by(&:position).map{ |x| x.record_id }
            story_item_id_sorted = story.set_items.sort_by(&:position).map{ |x| x._id.to_s }
            expect(presented_json[:record_ids].map{|item| item[:record_id] }).to eq(record_id_sorted)
            expect(presented_json[:record_ids].map{|item| item[:story_item_id] }).to eq(story_item_id_sorted)
          end
        end
      end
    end
  end
end
