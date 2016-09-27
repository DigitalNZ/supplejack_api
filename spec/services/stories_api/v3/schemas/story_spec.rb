module StoriesApi
  module V3
    module Schemas
      RSpec.describe Story do
        let(:valid_story) { build(:story, contents: [build(:heading_block)]) }

        it 'requires an id' do
          result = subject.call(valid_story.except(:id))

          expect(result.success?).to eq(false)
          expect(result.messages).to include(:id)
        end

        it 'requires a name' do
          result = subject.call(valid_story.except(:name))

          expect(result.success?).to eq(false)
          expect(result.messages).to include(:name)
        end

        it 'requires a description' do
          result = subject.call(valid_story.except(:description))

          expect(result.success?).to eq(false)
          expect(result.messages).to include(:description)
        end

        describe '#privacy' do
          context 'invalid' do
            it 'is invalid when missing' do
              result = subject.call(valid_story.except(:privacy))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:privacy)
            end

            it 'is invalid when valid privacy status' do
              result = subject.call(valid_story.update(privacy: 'visible'))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:privacy)
            end
          end

          context 'valid' do
            it 'is valid when it is a valid privacy status' do
              result = subject.call(valid_story)

              expect(result.success?).to eq(true)
            end
          end
        end

        describe '#featured' do
          context 'invalid' do
            it 'is invalid when missing' do
              result = subject.call(valid_story.except(:featured))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:featured)
            end

            it 'is invalid when set to a non boolean value' do
              result = subject.call(valid_story.update(featured: 'foo'))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:featured)
            end
          end

          context 'valid' do
            it 'is valid when set to a boolean value' do
              result = subject.call(valid_story)

              expect(result.success?).to eq(true)
            end
          end
        end

        describe '#tags' do
          context 'invalid' do
            it 'is invalid when missing' do
              result = subject.call(valid_story.except(:tags))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:tags)
            end

            it 'is invalid when set to a non array value' do
              result = subject.call(valid_story.update(tags: 'foo'))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:tags)
            end
          end

          context 'valid' do
            it 'is valid when set to an array of strings' do
              result = subject.call(valid_story)

              expect(result.success?).to eq(true)
            end
          end
        end

        describe '#approved' do
          context 'invalid' do
            it 'is invalid when missing' do
              result = subject.call(valid_story.except(:approved))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:approved)
            end

            it 'is invalid when set to a non boolean value' do
              result = subject.call(valid_story.update(approved: 'foo'))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:approved)
            end
          end

          context 'valid' do
            it 'is valid when set to a boolean value' do
              result = subject.call(valid_story)

              expect(result.success?).to eq(true)
            end
          end
        end

        describe '#number_of_items' do
          context 'invalid' do
            it 'is invalid when missing' do
              result = subject.call(valid_story.except(:number_of_items))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:number_of_items)
            end

            it 'is invalid when set to a non integer' do
              result = subject.call(valid_story.update(number_of_items: 'foo'))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:number_of_items)
            end

            it 'is invalid when set to a negative integer' do
              result = subject.call(valid_story.update(number_of_items: -1))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:number_of_items)
            end
          end

          context 'valid' do
            it 'is valid when set to a positive integer value' do
              result = subject.call(valid_story)

              expect(result.success?).to eq(true)
            end
          end
        end

        describe '#contents' do
          context 'invalid' do
            it 'is invalid when missing' do
              result = subject.call(valid_story.except(:contents))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:contents)
            end

            it 'is invalid when it contains malformed blocks' do
              result = subject.call(valid_story.update(contents: valid_story[:contents].map{|x| x.except(:meta)}))

              expect(result.success?).to eq(false)
              expect(result.messages).to include(:contents)
            end
          end

          context 'valid' do
            it 'is valid when contains valid blocks' do
              result = subject.call(valid_story)

              expect(result.success?).to eq(true)
            end
          end
        end

        it 'is valid for a valid story' do
          result = subject.call(valid_story)

          expect(result.success?).to eq(true)
        end
      end
    end
  end
end
