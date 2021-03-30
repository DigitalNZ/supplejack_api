# frozen_string_literal: true

module SupplejackApi
  module Stories
    class ModerationsController < SupplejackApplicationController
      respond_to :json
      before_action :authenticate_admin!

      def index
        user_sets = UserSet.moderation_search(index_params)

        render json: {
          sets: user_sets.map { |user_set| StoriesModerationSerializer.new(user_set) },
          total_filtered: user_sets.count,
          total: UserSet.public_not_favourites.count,
          page: index_params[:page]&.to_i || 1,
          per_page: index_params[:per_page]&.to_i || 10
        }
      end

      private

      def index_params
        params.permit(%i[page per_page order_by direction search])
      end
    end
  end
end
