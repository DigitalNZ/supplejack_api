# frozen_string_literal: true

module SupplejackApi
  class StoryItemsController < SupplejackApplicationController
    include Concerns::StoryItemsControllerMetrics

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

        render json: StoryItemSerializer.new(item).to_json(include_root: false), status: :ok
      else
        render_error_with(item.errors.messages.values.join(', '), :bad_request)
      end
    end

    def update
      if @item.update(item_params)
        if item_params[:meta] && item_params[:meta][:is_cover]
          @story.update_attribute(:cover_thumbnail, @item.content[:image_url])
        elsif @story.cover_thumbnail == @item.content[:image_url]
          @story.update_attribute(:cover_thumbnail, nil)
        end

        render json: StoryItemSerializer.new(@item).to_json(include_root: false), status: :ok
      else
        render_error_with('Failed to update', :bad_request)
      end
    end

    def destroy
      @item.destroy

      head :no_content
    end

    private

    def content_keys
      [
        :id,
        :record_id,
        :title,
        :display_collection,
        :image_url,
        :description,
        :value,
        :content_partner,
        { category: [], tags: [] }
      ]
    end

    def meta_keys
      [
        :align_mode,
        :is_cover,
        :caption,
        :title,
        :category,
        :alignment,
        :size,
        :metadata,
        { tags: [] }
      ]
    end

    def item_params
      params.require(:item).permit(
        :position,
        :type,
        :sub_type,
        :record_id,
        content: content_keys,
        meta: meta_keys
      )
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
