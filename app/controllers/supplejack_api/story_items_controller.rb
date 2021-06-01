# frozen_string_literal: true

module SupplejackApi
  class StoryItemsController < SupplejackApplicationController
    include Concerns::Stories
    # include Concerns::StoryItemsControllerMetrics

    before_action :story_user_check, except: :index
    before_action :find_story
    before_action :find_story_item, only: %i[show update destroy]
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
      item = @story.set_items.build(item_params)

      if item.valid?
        @story.cover_thumbnail = item.content[:image_url] unless @story.cover_thumbnail
        @story.save!

        # specs for postion change & setting is_cover url required

        #   if position
        #     StoriesApi::V3::Endpoints::Moves.new(story_id: story.id.to_s,
        #                                          user_key: user.api_key,
        #                                          item_id: story_item.id.to_s,
        #                                          position: position).post
        #     story_item.reload
        #   end

        render json: StoryItemSerializer.new(item).to_json(include_root: false), status: :ok
      else
        render_error_with(item.errors.messages.values.join(', '), :bad_request)
      end
    end

    def update
      render_response(:story_item)
    end

    def destroy
      @item.destroy

      head :no_content
    end

    private

    def item_params
      content_fields = [:id, :title, :display_collection, :value, :image_url, { category: [], tags: [] }]
      meta_fields = %i[alignment align_mode is_cover caption title size metadata]

      params.require(:item).permit(:position, :type, :sub_type, :record_id, content: content_fields, meta: meta_fields)
    end

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
