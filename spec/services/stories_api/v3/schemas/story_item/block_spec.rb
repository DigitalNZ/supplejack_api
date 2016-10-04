module StoriesApi
  module V3
    module Schemas
      module StoryItem
        RSpec.describe Block do
          let(:valid_block) { build(:story_block) }

          describe '#type' do
            it 'is invalid when missing' do
              result = subject.call(valid_block.except(:type))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:type)
            end

            it 'is invalid when an invalid block type is present' do
              result = subject.call(valid_block.update(type: 'foo'))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:type)
            end

            it 'is valid when a valid block type is present' do
              result = subject.call(valid_block)

              expect(result.success?).to eq(true)
            end
          end

          describe '#sub_type' do
            it 'is invalid when missing' do
              result = subject.call(valid_block.except(:sub_type))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:sub_type)
            end

            it 'is invalid when an invalid block type is present' do
              result = subject.call(valid_block.update(sub_type: 'foo'))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:sub_type)
            end

            it 'is valid when a valid block type is present' do
              result = subject.call(valid_block)

              expect(result.success?).to eq(true)
            end
          end
        end
      end
    end
  end
end
