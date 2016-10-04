module StoriesApi
  module V3
    module Presenters
      RSpec.describe StoryItem do
        let(:story_item) {build(:story_item)}
        let(:presented_json) {subject.call(story_item)}

        it 'presents the top level fields' do
          [:position, :type, :sub_type].each do |field|
            expect(presented_json[field]).to eq(story_item.send(field))
          end
        end

        it 'presents the content field' do
          expect(presented_json[:content][:value]).to eq(story_item.content[:value])
        end

        it 'presents the meta field' do
          expect(presented_json[:meta][:size]).to eq(story_item.meta[:size])
        end
      end
    end
  end
end
