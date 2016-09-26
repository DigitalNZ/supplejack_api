module StoriesApi
  module V3
    module Schemas
      module StoryItem
        module Text
          RichText = Dry::Validation.Schema(Block) do
            required(:content).schema do
              required(:value).filled(:str?)
            end
          end
        end
      end
    end
  end
end
