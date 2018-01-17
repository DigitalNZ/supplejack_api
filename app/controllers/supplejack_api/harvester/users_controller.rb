# frozen_string_literal: true

# This controller is used by the Manager to retrieve the user statistics.

module SupplejackApi
  module Harvester
    class UsersController < ApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def index
        @users = User.sortable(
          order: params[:order] || :daily_requests_desc, page: params[:page]
        )

        render json: @users, each_serializer: UserSerializer, root: 'users', adapter: :json
      end
    end
  end
end
