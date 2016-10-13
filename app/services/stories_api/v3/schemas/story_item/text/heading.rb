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
        module Text
          Heading = Dry::Validation.Schema(Block) do
            configure do
              def valid_sizes
                [1, 2, 3, 4, 5, 6]
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
