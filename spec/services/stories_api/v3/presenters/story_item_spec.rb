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

        describe '#content' do
          context 'block without a custom presenter' do
            it 'presents the attributes in the content field' do
              expect(presented_json[:content][:value]).to eq(story_item.content[:value])
            end
          end

          context 'block with a custom presenter' do
            let(:record) {create(:record)}
            let(:story_item) {build(:embed_dnz_item, id: record.record_id)}

            it 'hands off the content field to the custom presenter' do
            # FIXME This test isn't testing anything.  It is testing that nil is nil, because the key is not present on the hash or the record
              expect(presented_json[:content][:description]).to eq(record.description)
              expect(presented_json[:content][:title]).to eq('Untitled')
            end
          end
        end

        it 'presents the meta field' do
          expect(presented_json[:meta][:size]).to eq(story_item.meta[:size])
        end
      end
    end
  end
end
