# frozen_string_literal: true

module SupplejackApi
  class StoriesController < SupplejackApplicationController
    include Concerns::Stories
    include Concerns::StoriesControllerMetrics

    before_action :authenticate_admin!, only: [:admin_index]
    before_action :story_user_id_check!, only: [:admin_index]
    before_action :story_user_check!, except: %i[admin_index show]

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
      params[:slim] = false
      render_response(:story)
    end

    def create
      render_response(:stories)
    end

    def update
      render_response(:story)
    end

    def destroy
      render_response(:story)
    end

    private

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
  end
end
