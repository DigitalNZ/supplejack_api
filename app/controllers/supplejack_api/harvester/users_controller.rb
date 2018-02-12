# frozen_string_literal: true

# This controller is used by the Manager to retrieve information for the admin content.

module SupplejackApi
  module Harvester
    class UsersController < ApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def index
        render json: User.all, each_serializer: UserSerializer, root: 'users', adapter: :json
      end

      def show
        user = User.find(params[:id])

        render json: user, serializer: UserSerializer
      end

      def update
        user = User.find(params[:id])
        user.update_attributes!(user_params)
      end

      private

      def user_params
        params.require(:user).permit(:max_requests)
      end
    end
  end
end
