# frozen_string_literal: true

module SupplejackApi
  class StoryItemMovesController < ApplicationController
    include Concerns::Stories

    def create
      if params[:user_key]
        render_response(:moves)
      else
        render request.format.to_sym => {
          errors: 'Mandatory parameter user_key missing'
        }, status: 400
      end
    end
  end
end
