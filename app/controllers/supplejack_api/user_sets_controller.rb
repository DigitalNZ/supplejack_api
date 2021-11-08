# frozen_string_literal: true

module SupplejackApi
  class UserSetsController < SupplejackApplicationController
    include Concerns::UserSetsControllerMetrics

    respond_to :json

    before_action :prevent_anonymous!

    before_action :find_user_set, only: %i[update destroy]

    def index
      @user_sets = current_user.user_sets

      render json: @user_sets, root: 'sets', adapter: :json
    end

    def featured_sets_index
      @user_sets = UserSet.featured_sets(4)

      render json: @user_sets, root: 'sets', user: true, featured: true, adapter: :json
    end

    def show
      @user_set = UserSet.custom_find(params[:id])

      if @user_set
        render json: @user_set, user: true, root: 'set', full_set_items: true, adapter: :json
      else
        render json: { errors: I18n.t('errors.user_set_not_found', id: params[:id]) }, status: :not_found
      end
    end

    def create
      @user_set = current_user.user_sets.build

      if @user_set.update_attributes_and_embedded(set_params)
        render json: @user_set, user: true
      else
        render json: { errors: @user_set.errors.to_hash }, status: :unprocessable_entity
      end
    end

    def update
      if @user_set.update_attributes_and_embedded(set_params, current_user)
        render json: @user_set, user: true
      else
        render json: { errors: @user_set.errors.to_hash }, status: :unprocessable_entity
      end
    end

    def destroy
      @user_set.destroy

      respond_with(@user_set)
    end

    private

    def user_not_authorized
      render_error_with(I18n.t('errors.requires_admin_privileges'), :unauthorized)
    end

    rescue_from UserSet::WrongRecordsFormat do |_exception|
      render json: {
        errors: { records: ['The records array is not in a valid format.'] }
      }, status: :unprocessable_entity
    end

    def set_params
      # Not using require here because we handle missing params seperately.
      # require method throws and error if the :set is not there
      params[:set]&.permit(:id, :name, :approved, :description, :privacy, records: %i[record_id position]).to_h
    end
  end
end
