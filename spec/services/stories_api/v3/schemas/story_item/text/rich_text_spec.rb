# module StoriesApi
#   module V3
#     module Schemas
#       module StoryItem
#         module Text
#           RSpec.describe RichText do
#             let(:valid_block) { build(:rich_text_block) }

#             describe '#content' do
#               context 'valid' do
#                 it 'is valid with value present' do
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
