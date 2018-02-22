# frozen_string_literal: true



module StoriesApi
  module V3
    module Schemas
      module StoryItem
        module Embed
          Record = Dry::Validation.Schema(Block) do
            configure do
              def valid_alignments
                %w[left center right]
              end
            end

            required(:content).schema do
              required(:id).filled(:int?)
              optional(:title).filled(:str?)
              optional(:display_collection).filled(:str?)
              optional(:category).each(:str?)
              optional(:image_url).maybe(:str?)
              optional(:tags).each(:str?)
            end

            required(:meta).schema do
              optional(:alignment).filled(included_in?: valid_alignments)
              optional(:caption).maybe(:str?)
            end
          end
        end
      end
    end
  end
end
