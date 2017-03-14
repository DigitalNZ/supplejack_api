# frozen_string_literal: true
module SupplejackApi
  class StoriesController < ApplicationController
    include Concerns::Stories

    before_action :authenticate_admin!, only: [:admin_index]

    def index
      render_response(:stories)
    end

    # This route is created for front end application to get all stories for a user.
    # Application dont know about the user id but has the api_key for a user.
    # So in this nested route the user api_key is passed as the id.
    def admin_index
      params[:slim] = true
      params[:api_key] = params[:user_id]
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
