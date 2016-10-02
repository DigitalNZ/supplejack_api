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
    end
  end
end
