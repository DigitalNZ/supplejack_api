module StoriesApi
  module V3
    module Schemas
      module StoryItem
        module Embed
          RSpec.describe Dnz do
            let(:valid_block) { build(:embed_dnz_block) }

            def update_content_value(field, value)
              content = valid_block[:content]
              content[field] = value

              valid_block.update(content: content)
            end

            def update_record_value(field, value)
              record = valid_block[:content][:record]
              record[field] = value

              update_content_value(:record, record)
            end

            def update_meta_value(field, value)
              meta = valid_block[:meta]
              meta[field] = value

              valid_block.update(meta: meta)
            end

            def expect_content_message(field, result)
              expect(result.messages).to include(content: include(field))
            end

            def expect_record_message(field, result)
              expect(result.messages).to include(content: include(record: include(field)))
            end

            it 'is valid for a valid block' do
              expect(subject.call(valid_block).success?).to eq(true)
            end

            describe '#content' do
              describe '#record_id' do
                it 'must be an integer' do
                  result = subject.call(update_content_value(:record_id, '123'))

                  expect(result.success?).to eq(false)
                  expect_content_message(:record_id, result)
                end

                it 'must be present' do
                  result = subject.call(valid_block.dup.update(content: valid_block[:content].except(:record_id)))

                  expect(result.success?).to eq(false), "schema failed to validate 'record_id' as required"
                  expect_content_message(:record_id, result)
                end
              end

              describe '#record' do
                let(:required_fields) do
                  [
                    :title,
                    :display_collection,
                    :category,
                    :image_url,
                    :tags
                  ]
                end

                it 'requires all the required fields' do
                  required_fields.each do |field|
                    result = subject.call(
                      valid_block.dup.update(
                        content: valid_block[:content].update(record: valid_block[:content][:record].except(field))
                      )
                    )

                    expect(result.success?).to eq(false), "schema failed to validate '#{field}' as required"
                    expect_record_message(field, result)
                  end
                end

                describe '#title' do
                  it 'must be a string' do
                    result = subject.call(update_record_value(:title, 123))

                    expect(result.success?).to eq(false)
                    expect_record_message(:title, result)
                  end
                end

                describe '#display_collection' do
                  it 'must be a string' do
                    result = subject.call(update_record_value(:display_collection, 123))

                    expect(result.success?).to eq(false)
                    expect_record_message(:display_collection, result)
                  end
                end

                describe '#category' do
                  it 'must be a string' do
                    result = subject.call(update_record_value(:category, 123))

                    expect(result.success?).to eq(false)
                    expect_record_message(:category, result)
                  end
                end

                describe '#image_url' do
                  it 'must be a string' do
                    result = subject.call(update_record_value(:image_url, 123))

                    expect(result.success?).to eq(false)
                    expect_record_message(:image_url, result)
                  end
                end

                describe '#tags' do
                  it 'must be an array of strings' do
                    result = subject.call(update_record_value(:tags, 123))

                    expect(result.success?).to eq(false)
                    expect_record_message(:tags, result)
                  end
                end
              end
            end

            describe '#meta' do
              describe '#alignment' do
                it 'must be a valid alignment' do
                  result = subject.call(update_meta_value(:alignment, 'bad-alignment'))

                  expect(result.success?).to eq(false)

                  result = subject.call(update_meta_value(:alignment, 'left'))

                  expect(result.success?).to eq(true)
                end
              end

              describe '#caption' do
                it 'must be a string' do
                  result = subject.call(update_meta_value(:caption, 123))

                  expect(result.success?).to eq(false)
                end
              end
            end
          end
        end
      end
    end
  end
end
