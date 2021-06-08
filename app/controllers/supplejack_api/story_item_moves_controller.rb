# frozen_string_literal: true

module SupplejackApi
  class StoryItemMovesController < SupplejackApplicationController
    include Concerns::Stories

    def create
      if params[:user_key]
        # When this DRY code is removed
        # app/services/stories_api/v3/presenters/content/embed/record.rb can be deleted
        render_response(:moves)
      else
        render request.format.to_sym => {
          errors: 'Mandatory parameter user_key missing'
        }, status: :bad_request
      end
    end
  end
end
