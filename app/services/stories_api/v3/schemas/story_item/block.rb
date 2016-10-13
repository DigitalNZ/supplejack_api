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
        class Block < Dry::Validation::Schema
          def valid_types
            %w(embed text)
          end

          def valid_sub_types
            %w(dnz heading rich_text)
          end

          define! do
            required(:type).filled(included_in?: valid_types)
            required(:sub_type).filled(included_in?: valid_sub_types)
          end
        end
      end
    end
  end
end
