# frozen_string_literal: true
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
        def initialize(user_id)
          super(404, "User with provided Api Key #{user_id} not found")
        end
      end

      class StoryNotFound < Base
        def initialize(story_id)
          super(404, "Story with provided Id #{story_id} not found")
        end
      end

      class StoryItemNotFound < Base
        def initialize(item_id, story_id)
          super(404, "StoryItem with provided Id #{item_id} not found for Story with provided Story Id #{story_id}")
        end
      end

      class MandatoryParamMissing < Base
        def initialize(param)
          super(422, "Mandatory Parameter #{param} missing in request")
        end
      end

      class UnsupportedFieldType < Base
        def initialize(field, value)
          super(415, "Unsupported value #{value} for parameter #{field}")
        end
      end

      class SchemaValidationError < Base
        def initialize(errors)
          message = ''
          errors.each do |field, subfields|
            message = if subfields.is_a? Hash
                        subfields.values.flatten.join(', ') + " in #{field}"
                      else
                        subfields[0]
                      end
          end

          error_code = message.include?('missing') ? 422 : 400
          super(error_code, "Bad Request. #{message}")
        end
      end
    end
  end
end
