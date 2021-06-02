# module StoriesApi
#   module V3
#     module Schemas
#       module StoryItem
#         module Text
#           RSpec.describe Heading do
#             let(:valid_block) {build(:heading_block)}

#             describe '#content' do
#               context 'invalid' do
#                 it 'requires a value' do
#                   result = subject.call(valid_block.update(content: {}))

#                   expect(result.success?).to eq(false)
#                   expect(result.messages).to include(:content)
#                 end
#               end

#               context 'valid' do
#                 it 'is valid with value present' do
#                   result = subject.call(valid_block)

#                   expect(result.success?).to eq(true)
#                 end
#               end
#             end

#             describe '#meta' do
#               context 'invalid' do
#                 it 'size is outside of valid range' do
#                   result = subject.call(valid_block.update(meta: {size: 0}))

#                   expect(result.success?).to eq(false)
#                   expect(result.messages).to include(meta: include(:size))

#                   result = subject.call(valid_block.update(meta: {size: 7}))

#                   expect(result.success?).to eq(false)
#                   expect(result.messages).to include(meta: include(:size))
#                 end
#               end

#               context 'valid' do
#                 it 'is valid with nothing in it' do
#                   result = subject.call(valid_block.update(meta: {}))

#                   expect(result.success?).to eq(true)
#                 end

#                 it 'is valid with a valid header size' do
#                   result = subject.call(valid_block)

#                   expect(result.success?).to eq(true)
#                 end
#               end
#             end
#           end
#         end
#       end
#     end
#   end
# end
