# frozen_string_literal: true

module SupplejackApi
  class StoriesController < SupplejackApplicationController
    include Concerns::Stories
    # include Concerns::StoriesControllerMetrics

    before_action :authenticate_admin!, :story_user_id_check!, only: [:admin_index]
    before_action :story_user_check!, except: %i[admin_index show]
    before_action :find_story, only: %i[show update destroy]

    def index
      slim = params[:slim] != 'false'

      render json: stories_of(current_story_user, slim).to_json(include_root: false), status: :ok
    end

    # This route is created for front end application to get all stories for a user.
    # Application dont know about the user id but has the api_key for a user.
    # So in this nested route the user api_key is passed as the id.
    def admin_index
      render json: stories_of(@story_user, true).to_json(include_root: false), status: :ok
    end

    def show
      if @story.privacy == 'private'
        if @story.user == current_story_user || current_story_user&.admin?
          render json: StorySerializer.new(@story, slim: false).to_json(include_root: false), status: :ok
        else
          render json: { errors: "Story with provided Id #{params[:id]} is private story and requires the creator's key as user_key" }.to_json(include_root: false), status: :ok
        end
      else
        render json: StorySerializer.new(@story, slim: false).to_json(include_root: false), status: :ok
      end
    end

    def create
      story = current_story_user.user_sets.build(name: story_params[:name])

      if story.valid?
        story.save!
        render json: StorySerializer.new(story, slim: false).to_json(include_root: false), status: :created
      else
        render json: { errors: story.errors[:name] }.to_json(include_root: false), status: :bad_request
      end
    end

    def update
      render_response(:story)
    end

    def destroy
      @story.destroy

      head :no_content
    end

    private

    def story_params
      params.require(:story).permit(:name).to_h
    end

    def stories_of(user, slim)
      user.user_sets.order_by(updated_at: 'desc').map do |user_set|
        StorySerializer.new(user_set, slim: slim)
      end
    end

    def story_user_id_check!
      @story_user = User.find_by_api_key(params[:user_id])

      render request.format.to_sym => {
        errors: "User with provided user id #{params[:user_id]} not found"
      }, status: :not_found unless @story_user
    end

    def find_story
      @story = SupplejackApi::UserSet.custom_find(params[:id])

      render request.format.to_sym => {
        errors: "Story with provided Id #{params[:id]} not found"
      }, status: :not_found unless @story
    end
  end
end
