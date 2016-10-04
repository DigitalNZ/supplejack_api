# frozen_string_literal: true
module StoriesApi
  module V3
    module Schemas
      module StoryItem
        module Embed
          Dnz = Dry::Validation.Schema(Block) do
            configure do
              def valid_alignments
                %w(left center right)
              end
            end

            required(:content).schema do
              required(:id).filled(:int?)
              required(:title).filled(:str?)
              required(:display_collection).filled(:str?)
              required(:category).filled(:str?)
              required(:image_url).filled(:str?)
              required(:tags).each(:str?)
            end

            required(:meta).schema do
              optional(:alignment).filled(included_in?: valid_alignments)
              optional(:caption).filled(:str?)
            end
          end
        end
      end
    end
  end
end
