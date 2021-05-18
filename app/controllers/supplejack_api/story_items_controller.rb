# frozen_string_literal: true

module SupplejackApi
  class StoryItemsController < SupplejackApplicationController
    include Concerns::Stories
    include Concerns::StoryItemsControllerMetrics

    before_action :story_user_check!, except: %i[create update destroy]

    def index
      render_response(:story_items)
    end

    def show
      render_response(:story_item)
    end

    def create
      render_response(:story_items)
    end

    def update
      render_response(:story_item)
    end

    def destroy
      render_response(:story_item)
    end
  end
end
