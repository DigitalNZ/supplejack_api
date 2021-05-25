# frozen_string_literal: true

module SupplejackApi
  class StoryItemsController < SupplejackApplicationController
    include Concerns::Stories
    include Concerns::StoryItemsControllerMetrics

    before_action :story_user_check, except: :index
    before_action :find_story, only: :index
    before_action :story_user_check, except: %i[create update destroy]

    def index
      render json: @story.set_items,
             each_serializer: StoryItemSerializer,
             root: false
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

    private

    def find_story
      @story = SupplejackApi::UserSet.find_by_id(params[:story_id])

      render_error_with(I18n.t('errors.story_not_found', id: params[:story_id]), :not_found) unless @story
    end
  end
end
