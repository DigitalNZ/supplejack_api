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
