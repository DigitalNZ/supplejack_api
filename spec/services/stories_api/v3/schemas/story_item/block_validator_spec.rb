module StoriesApi
  module V3
    module Schemas
      module StoryItem
        RSpec.describe BlockValidator do
          let(:rich_text_block) { build(:rich_text_block) }

          it 'validates a block against the correct schema based on type/sub_type' do
            subject.call(rich_text_block)
            expect(subject.valid).to eq(true)

            subject.call(rich_text_block.update(sub_type: 'heading'))
            expect(subject.valid).to eq(false)
          end

          describe '#messages' do
            it 'returns the validation error messages' do
              subject.call(rich_text_block.update(sub_type: 'heading'))

              expect(subject.messages).to eq(status: 422,
                                             exception: {
                                               message: 'Bad Request. meta is missing' })
            end
          end
        end
      end
    end
  end
end
