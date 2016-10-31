# frozen_string_literal: true
module SupplejackApi
  class StoriesController < ApplicationController
    include Concerns::Stories

    before_action :authenticate_admin!, only: [:admin_index]

    def index
      params[:user_id] = params[:api_key]

      render_response(:stories)
    end

    def admin_index
      render_response(:stories)
    end

    def show
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
