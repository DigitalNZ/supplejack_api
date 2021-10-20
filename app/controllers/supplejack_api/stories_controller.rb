# frozen_string_literal: true

module SupplejackApi
  class StoriesController < SupplejackApplicationController
    include Pundit
    include Concerns::IgnoreMetrics

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    before_action :authenticate_admin!, :story_user_id_check, only: [:admin_index]
    before_action :story_user_check, except: %i[admin_index show]
    before_action :find_story, only: %i[show update destroy reposition_items]
    after_action :create_story_record_views, only: :show

    def index
      render json: current_story_user.user_sets.order_by(updated_at: 'desc'),
             each_serializer: StorySerializer,
             scope: { slim: params[:slim] != 'false' },
             root: false
    end

    # This route is created for front end application to get all stories for a user.
    # Application dont know about the user id but has the api_key for a user.
    # So in this nested route the user api_key is passed as the id.
    def admin_index
      render json: @story_user.user_sets.order_by(updated_at: 'desc'),
             each_serializer: StorySerializer,
             root: false, scope: { slim: true }
    end

    def show
      authorize(@story)

      render json: StorySerializer.new(@story, scope: { slim: false }).to_json(include_root: false), status: :ok
    end

    def create
      story = current_story_user.user_sets.build(story_params)

      if story.valid?
        story.save!
        render json: StorySerializer.new(story, scope: { slim: false }).to_json(include_root: false), status: :created
      else
        render_error_with(story.errors.messages, :bad_request)
      end
    end

    def update
      authorize(@story)

      if @story.update(story_params)
        render json: StorySerializer.new(@story, scope: { slim: false }).to_json(include_root: false), status: :ok
      else
        render_error_with(@story.errors.messages, :bad_request)
      end
    end

    def destroy
      @story.destroy

      head :no_content
    end

    def reposition_items
      if @story.reposition_items(params[:items])
        head :ok
      else
        render json: { errors: I18n.t('errors.reposition_error') }, status: :bad_request
      end
    end

    def multiple_add
      stories = multiple_stories_params['stories'].each_with_object([]) do |story, stories|
        set = SupplejackApi::UserSet.custom_find(story['id'])
        return render_error_with(I18n.t('errors.story_not_found', id: story['id']), :not_found) unless set

        authorize(set)
        stories.push(set)
      end

      changes = multiple_stories_params['stories'].each_with_object([]) do |story_params, changes|
        set = stories.find { |s| s.id.to_s == story_params['id'] }

        item_ids = story_params['items'].each_with_object([]) do |item, ids|
          item = set.set_items.build(item)

          if item.valid?
            ids.push(item.id)
          else
            return render_error_with(item.errors.messages.values.join(', '), :bad_request)
          end
        end

        set.save!

        changes.push({
          story_id: story_params['id'],
          item_ids: item_ids
        })
      end

      render json: changes
    end

    def multiple_remove
      stories = multiple_stories_params['stories'].each_with_object([]) do |story, stories|
        set = SupplejackApi::UserSet.custom_find(story['id'])
        return render_error_with(I18n.t('errors.story_not_found', id: story['id']), :not_found) unless set

        authorize(set)
        stories.push(set)
      end

      multiple_stories_params['stories'].each do |story_params|
        set = stories.find { |s| s.id.to_s == story_params['id'] }

        story_params['items'].each do |item|
          set_item = set.set_items.find_by_id(item[:id])

          if set_item
            set_item.destroy!
          else
            return render json: { errors: I18n.t('errors.record_not_found', id: item[:id]) }, status: :not_found
          end
        end

        set.save!
      end

      head :no_content
    end

    def multiple_stories_params
      params.permit(:api_key, stories: [:id, items: [:id, :position, :type, :sub_type, :image_url, :display_collection, :category, :meta, :record_id, content: [:value, :image_url, :display_collection, :category]]])
    end

    def story_params
      fields = [:name, :description, :privacy, :copyright, :cover_thumbnail, { tags: [], subjects: [] }]

      params.require(:story).permit(fields)
    end

    def story_user_id_check
      @story_user = User.find_by_auth_token(params[:user_id])

      render_error_with(I18n.t('errors.user_with_id_not_found', id: params[:user_id]), :not_found) unless @story_user
    end

    def find_story
      @story = SupplejackApi::UserSet.custom_find(params[:id] || params[:story_id])

      render_error_with(I18n.t('errors.story_not_found', id: params[:id]), :not_found) unless @story
    end

    def pundit_user
      current_story_user
    end

    def user_not_authorized
      render_error_with(I18n.t('errors.user_not_authorized_for_story'), :unauthorized)
    end

    def create_story_record_views
      return unless log_request_for_metrics?

      payload = JSON.parse(response.body)
      log = payload['contents']&.map do |record|
        { record_id: record['record_id'], display_collection: record['content']['display_collection'] }
      end

      SupplejackApi::RequestMetric.spawn(log, 'user_story_views') if log
    end


  end
end
