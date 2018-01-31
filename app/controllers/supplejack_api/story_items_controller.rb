# frozen_string_literal: true

module SupplejackApi
  class StoryItemsController < ApplicationController
    include Concerns::Stories
    include Concerns::StoriesMetrics

    before_action :user_key_check!, except: %i[create update destroy]

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
