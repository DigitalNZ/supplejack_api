# frozen_string_literal: true
module StoriesApi
  module V3
    # This Module is exclusively written
    # Erros for StoriesApi.
    module Errors
      class Base
        attr_reader :error
        def set(status = nil, message = nil)
          @error = { status: status, exception: { message: message } }
        end
      end

      class UserNotFound < Base
        def initialize(user_id)
          set(404, "User with provided Api Key #{user_id} not found")
        end
      end

      class StoryNotFound < Base
        def initialize(story_id)
          set(404, "Story with provided Id #{story_id} not found")
        end
      end

      class MandatoryParamMissing < Base
        def initialize(param)
          set(422, "Mandatory Parameter #{param} missing in request")
        end
      end

      class UnsupportedFieldType < Base
        def initialize(field, value)
          set(415, "Unsupported value #{value} for parameter #{field}")
        end
      end

      class SchemaValidationError < Base
        def initialize(errors)
          message = ''
          errors.each do |field, subfields|
            message = if subfields.is_a? Hash
              subfields.map { |k, v| "#{field} #{k} #{v[0]}" }.join(', ')
            else
              "#{field} #{subfields[0]}"
            end
          end

          error_code = message.include?('missing') ? 422 : 400
          set(error_code, "Bad Request. #{message}")
        end
      end
    end
  end
end
