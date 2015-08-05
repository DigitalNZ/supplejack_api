# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UserSetsController < ApplicationController

    respond_to :json

    before_filter :find_user_set, only: [:update, :destroy]
    before_filter :authenticate_admin!, only: [:admin_index, :public_index]

    def index
      @user_sets = current_user.user_sets
      render json: serializable_array(@user_sets).to_json
    end

    # Endpoint for the administrator to get a list of sets for any user.
    #
    def admin_index
      @user = User.find_by_api_key(params[:user_id])

      if @user
        @user_sets = @user.user_sets
        render json: serializable_array(@user_sets).to_json
      else
        render json: {errors: "The user with api key: '#{params[:user_id]}' was not found" }, status: :not_found
      end
    end

    # Enpoint for the administrator to fetch a list of all public sets
    #
    def public_index
      @user_sets = UserSet.public_sets(page: params[:page])
      render json: serializable_array(@user_sets, user: true, total: true).to_json
    end

    def featured_sets_index
      @user_sets = UserSet.featured_sets(4)
      render json: serializable_array(@user_sets, user: true, featured: true).to_json
    end

    def show
      @user_set = UserSet.custom_find(params[:id])
      if @user_set
        SupplejackApi::RequestLog.create_user_set(@user_set, params[:request_logger_field]) if params[:request_logger]
        render json: UserSetSerializer.new(@user_set, user: current_user)
      else
        render json: {errors: "Set with id: #{params[:id]} was not found."}, status: :not_found
      end
    end

    def create
      @user_set = current_user.user_sets.build
      if @user_set.update_attributes_and_embedded(params[:set])
        render json: UserSetSerializer.new(@user_set, user: true)
      else
        render json: {errors: @user_set.errors.to_hash}, status: :unprocessable_entity
      end
    end

    def update
      if @user_set.update_attributes_and_embedded(params[:set], current_user)
        render json: UserSetSerializer.new(@user_set, user: true)
      else
        render json: {errors: @user_set.errors.to_hash}, status: :unprocessable_entity
      end
    end

    def destroy
      @user_set.destroy
      respond_with(@user_set)
    end

    private

    def serializable_array(user_sets, options={})
      options.reverse_merge!(root: false, items: false, user: false, total: false)
      hash = {"sets" => []}
      user_sets.each do |set|
        hash["sets"] << UserSetSerializer.new(set, options).as_json
      end
      hash["total"] = UserSet.public_sets_count if options[:total]
      hash
    end

    rescue_from UserSet::WrongRecordsFormat do |exception|
      render json: {errors: {records: ["The records array is not in a valid format."]}}, status: :unprocessable_entity
    end
  end
end
