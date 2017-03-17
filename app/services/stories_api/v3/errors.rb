# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module StoriesApi
  module V3
    # This Module is exclusively written
    # Erros for StoriesApi.
    module Errors
      class Base
        attr_reader :error
        def initialize(status = nil, message = nil)
          @error = { status: status, exception: { message: message } }
        end
      end

      class UserNotFound < Base
        def initialize(id: nil)
          super(404, "User with provided Api Key #{id} not found")
        end
      end

      class StoryNotFound < Base
        def initialize(id: nil)
          super(404, "Story with provided Id #{id} not found")
        end
      end

      class PrivateStoryNotAuthorised < Base
        def initialize(id: nil)
          super(401, "Story with provided Id #{id} is private story and requires the creator's key as user_key")
        end
      end

      class StoryItemNotFound < Base
        def initialize(item_id: nil, story_id: nil)
          super(404, "StoryItem with provided Id #{item_id} not found for Story with provided Story Id #{story_id}")
        end
      end

      class MandatoryParamMissing < Base
        def initialize(param: nil)
          super(400, "Mandatory Parameter #{param} missing in request")
        end
      end

      class UnsupportedFieldType < Base
        def initialize(value: nil, param: nil)
          super(400, "Unsupported value #{value} for parameter #{param}")
        end
      end

      class SchemaValidationError < Base
        def initialize(errors: nil)
          messages = ''
          errors.each do |field, subfields|
            message = if subfields.is_a? Hash
                        subfields.values.flatten.join(', ') + " in #{field}"
                      else
                        subfields[0]
                      end
            messages += " #{message}"
          end

          message = if messages.include? 'missing'
                      "Mandatory Parameters Missing: #{messages.strip}"
                    elsif messages.include? 'must be one of'
                      "Unsupported Values: #{messages.strip}"
                    else
                      "Bad Request: #{messages.strip}"
                    end

          super(400, message)
        end
      end
    end
  end
end
