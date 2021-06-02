# # frozen_string_literal: true
# module StoriesApi
#   module V3
#     module Schemas
#       module StoryItem
#         RSpec.describe BlockValidator do
#           let(:rich_text_block) { build(:rich_text_block) }

#           it 'validates a block against the correct schema based on type/sub_type' do
#             validation = subject.call(rich_text_block)
#             expect(validation.success?).to eq(true)

#             validation = subject.call(rich_text_block.update(sub_type: 'heading'))
#             expect(validation.success?).to eq(false)
#           end

#           describe '#messages' do
#             it 'returns the validation error messages' do
#               validation = subject.call(rich_text_block.update(sub_type: 'heading'))

#               expect(validation.messages).to eq(meta: ['is missing'])
#             end
#           end
#         end
#       end
#     end
#   end
# end
