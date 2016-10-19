module SupplejackApi
  class StoryItemMovesController < ApplicationController
    include Concerns::Stories

    def create
      render_response(:moves)
    end
  end
end
