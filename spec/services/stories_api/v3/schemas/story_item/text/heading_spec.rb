module StoriesApi
  module V3
    module Schemas
      module StoryItem
        module Text
          RSpec.describe Heading do
            describe '#content' do
              context 'invalid' do
                let(:validation_result) {subject.call(content: {})}

                it 'requires a value' do
                  expect(validation_result.success?).to eq(false)
                  expect(validation_result.messages).to include(:content)
                end
              end
            end
          end
        end
      end
    end
  end
end
