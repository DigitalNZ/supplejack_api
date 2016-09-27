# frozen_string_literal: true
module StoriesApi
  module V3
    module Endpoints
      class Stories
        attr_reader :params

        def initialize(params)
          @params = params
        end

        def get
          user = params[:user]

          user_account = SupplejackApi::User.find_by_api_key(user)

          unless user_account.present?
            return {
              status: 404,
              exception: {
                message: 'User with provided Id not found'
              }
            }
          end
        end

        def post
        end
      end
    end
  end
end
