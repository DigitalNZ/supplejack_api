# frozen_string_literal: true

module SupplejackApi
  module Stories
    class ModerationsController < SupplejackApplicationController
      respond_to :json
      before_action :authenticate_admin!

      def index
        page      = index_params[:page]&.to_i        || 1
        per_page  = index_params[:per_page]&.to_i    || 10
        order_by  = index_params[:order_by]&.to_sym  || :updated_at
        direction = index_params[:direction]&.to_sym || :asc
        search    = index_params[:search]

        @user_sets = UserSet.search(page, per_page, order_by, direction, search)
        render json: {
          sets: @user_sets.map { |user_set| StoriesModerationSerializer.new(user_set) },
          total: UserSet.public_sets_count,
          page: page,
          per_page: per_page
        }
      end

      private

      def index_params
        params.permit(%i[page per_page search order_by direction])
      end
    end
  end
end
