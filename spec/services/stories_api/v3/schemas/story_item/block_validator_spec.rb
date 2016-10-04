module StoriesApi
  module V3
    module Schemas
      module StoryItem
        RSpec.describe BlockValidator do
          let(:rich_text_block) { build(:rich_text_block) }

          it 'validates a block against the correct schema based on type/sub_type' do
            expect(subject.call(rich_text_block)).to eq(true)

            expect(subject.call(rich_text_block.update(sub_type: 'heading'))).to eq(false)
          end

          describe '#messages' do
            it 'returns the validation error messages' do
              subject.call(rich_text_block.update(sub_type: 'heading'))

              expect(subject.messages).to include(:meta)
            end
          end
        end
      end
    end
  end
end
