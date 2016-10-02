# frozen_string_literal: true
module StoriesApi
  module V3
    module Errors
      class UserNotFound
        attr_reader :error
        def initialize(user_id)
          @error = {
                      status: 404,
                      exception: {
                        message: "User with provided Api Key #{user_id} not found"
                      }
                    }
        end
      end

      class StoryNotFound
        attr_reader :error
        def initialize(story_id)
          @error = {
                      status: 404,
                      exception: {
                        message: "Story with provided Id #{story_id} not found"
                      }
                    }          
        end        
      end      
    end
  end
end