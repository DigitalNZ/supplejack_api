# frozen_string_literal: true

module SupplejackApi
  module Stories
    class ModerationsController < ApplicationController
      respond_to :json
      before_action :authenticate_admin!

      def index
        @user_sets = UserSet.all_public_sets
        render json: @user_sets, each_serializer: StoriesModerationSerializer,
               root: 'sets', adapter: :json
      end
    end
  end
end
