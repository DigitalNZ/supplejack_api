# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
