# module StoriesApi
#   module V3
#     module Schemas
#       module StoryItem
#         module Embed
#           RSpec.describe Record do
#             let(:valid_block) { build(:embed_dnz_block) }

#             def update_content_value(field, value)
#               content = valid_block[:content]
#               content[field] = value

#               valid_block.update(content: content)
#             end

#             def update_meta_value(field, value)
#               meta = valid_block[:meta]
#               meta[field] = value

#               valid_block.update(meta: meta)
#             end

#             def expect_content_message(field, result)
#               expect(result.messages).to include(content: include(field))
#             end

#             it 'is valid for a valid block' do
#               expect(subject.call(valid_block).success?).to eq(true)
#             end

#             describe '#content' do
#               describe '#id' do
#                 it 'must be an integer' do
#                   result = subject.call(update_content_value(:id, '123'))

#                   expect(result.success?).to eq(false)
#                   expect_content_message(:id, result)
#                 end

#                 it 'must be present' do
#                   result = subject.call(valid_block.dup.update(content: valid_block[:content].except(:id)))

#                   expect(result.success?).to eq(false), "schema failed to validate 'id' as required"
#                   expect_content_message(:id, result)
#                 end
#               end

#               context 'record attributes' do
#                 describe '#title' do
#                   it 'must be a string' do
#                     result = subject.call(update_content_value(:title, 123))

#                     expect(result.success?).to eq(false)
#                     expect_content_message(:title, result)
#                   end
#                 end

#                 describe '#display_collection' do
#                   it 'must be a string' do
#                     result = subject.call(update_content_value(:display_collection, 123))

#                     expect(result.success?).to eq(false)
#                     expect_content_message(:display_collection, result)
#                   end
#                 end

#                 describe '#category' do
#                   it 'must be a string' do
#                     result = subject.call(update_content_value(:category, 123))

#                     expect(result.success?).to eq(false)
#                     expect_content_message(:category, result)
#                   end
#                 end

#                 describe '#image_url' do
#                   it 'must be a string' do
#                     result = subject.call(update_content_value(:image_url, 123))

#                     expect(result.success?).to eq(false)
#                     expect_content_message(:image_url, result)
#                   end

#                   it 'can be nil' do
#                     result = subject.call(update_content_value(:image_url, nil))

#                     expect(result.success?).to eq(true)
#                   end                  
#                 end

#                 describe '#tags' do
#                   it 'must be an array of strings' do
#                     result = subject.call(update_content_value(:tags, 123))

#                     expect(result.success?).to eq(false)
#                     expect_content_message(:tags, result)
#                   end
#                 end
#               end
#             end

#             describe '#meta' do
#               describe '#alignment' do
#                 it 'must be a valid alignment' do
#                   result = subject.call(update_meta_value(:alignment, 'bad-alignment'))

#                   expect(result.success?).to eq(false)

#                   result = subject.call(update_meta_value(:alignment, 'left'))

#                   expect(result.success?).to eq(true)
#                 end
#               end

#               describe '#caption' do
#                 it 'must be a nil' do
#                   result = subject.call(update_meta_value(:caption, nil))

#                   expect(result.success?).to eq(true)
#                 end

#                 it 'must be a empty string' do
#                   result = subject.call(update_meta_value(:caption, ''))

#                   expect(result.success?).to eq(true)
#                 end

#                 it 'must be a string' do
#                   result = subject.call(update_meta_value(:caption, 123))

#                   expect(result.success?).to eq(false)
#                 end
#               end
#             end
#           end
#         end
#       end
#     end
#   end
# end
