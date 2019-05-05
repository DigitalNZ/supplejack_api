# frozen_string_literal: true

module SupplejackApi
  module Stories
    class ModerationsController < SupplejackApplicationController
      respond_to :json
      before_action :authenticate_admin!

      def index
        user_sets = UserSet.public_search(index_params)
        render json: {
          sets: user_sets.map { |user_set| StoriesModerationSerializer.new(user_set) },
          total: UserSet.public_sets_count,
          page: index_params[:page],
          per_page: index_params[:per_page]
        }
      end

      private

      def index_params
        params.permit(%i[page per_page order_by direction search])
      end
    end
  end
end
