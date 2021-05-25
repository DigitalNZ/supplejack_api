# frozen_string_literal: true

module SupplejackApi
  class StoryItemsController < SupplejackApplicationController
    include Concerns::Stories
    include Concerns::StoryItemsControllerMetrics

    before_action :story_user_check, except: :index
    before_action :find_story, only: %i[index show destroy]
    before_action :find_story_item, only: %i[show destroy]
    before_action :story_user_check, except: %i[create update destroy]

    def index
      render json: @story.set_items,
             each_serializer: StoryItemSerializer,
             root: false
    end

    def show
      render json: StoryItemSerializer.new(@item).to_json(include_root: false), status: :ok
    end

    def create
      render_response(:story_items)
    end

    def update
      render_response(:story_item)
    end

    def destroy
      @item.destroy

      head :no_content
    end

    private

    def find_story
      @story = SupplejackApi::UserSet.find_by_id(params[:story_id])

      render_error_with(I18n.t('errors.story_not_found', id: params[:story_id]), :not_found) unless @story
    end

    def find_story_item
      @item = @story.set_items.find_by_id(params[:id])

      render_error_with(I18n.t('errors.story_item_not_found', id: params[:id], story_id: params[:story_id]),
                        :not_found) unless @item
    end
  end
end
