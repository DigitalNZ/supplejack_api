# frozen_string_literal: true

module SupplejackApi
  class StoriesController < SupplejackApplicationController
    include Concerns::Stories
    include Concerns::StoriesControllerMetrics

    before_action :authenticate_admin!, only: [:admin_index]
    before_action :user_key_check!, except: %i[admin_index show]

    def index
      current_user = SupplejackApi::User.find_by_api_key(params[:user_key])

      response = if current_user.blank?
                   { errors: "User with provided Api Key #{params[:user_key]} not found" }
                 else
                   current_user.user_sets.order_by(updated_at: 'desc').map do |user_set|
                     StorySerializer.new(user_set, slim: params[:slim] != 'false')
                   end
                 end

      # Deal with the status
      render json: response.to_json(include_root: false), status: :ok
    end

    # This route is created for front end application to get all stories for a user.
    # Application dont know about the user id but has the api_key for a user.
    # So in this nested route the user api_key is passed as the id.
    def admin_index
      params[:slim] = true
      params[:user_key] = params[:user_id]
      render_response(:stories)
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
  end
end
