module StoriesApi
  module V3
    module Presenters
      RSpec.describe Story do
        let(:story) {create(:story)}
        let(:presented_json) {subject.call(story)}

        it 'presents all top level fields' do
          [:name, :description, :privacy, :featured, :approved, :tags].each do |field|
            expect(presented_json[field]).to eq(story.send(field))
          end
        end

        it 'presents the id field as a string' do
          expect(presented_json[:id]).to eq(story.id.to_s)
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
      end
    end
  end
end
