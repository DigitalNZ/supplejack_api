module StoriesApi
  module V3
    module Schemas
      module StoryItem
        module Text
          Heading = Dry::Validation.Schema(Block) do
            configure do
              def valid_sizes
                %w(1 2 3 4 5 6)
              end
            end

            required(:content).schema do
              required(:value).filled(:str?)
            end

            required(:meta).schema do
              optional(:size).filled(included_in?: valid_sizes)
            end
          end
        end
      end
    end
  end
end
