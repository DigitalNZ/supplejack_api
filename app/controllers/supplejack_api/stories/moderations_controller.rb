# frozen_string_literal: true

module SupplejackApi
  module Stories
    class ModerationsController < SupplejackApplicationController
      include Pundit

      rescue_from Pundit::NotAuthorizedError, with: :user_requires_admin_privileges
      respond_to :json

      def index
        authorize(UserSet)

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
