# frozen_string_literal: true
module SupplejackApi
  class StoryItemMovesController < ApplicationController
    include Concerns::Stories

    def create
      unless params[:user_key]
      render request.format.to_sym => {
          errors: 'Mandatory parameter user_key missing'
        }, status: 400
      else
        render_response(:moves)
      end
    end
  end
end
