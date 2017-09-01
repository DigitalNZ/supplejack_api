# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UsersController < ApplicationController
    respond_to :xml, :json
    before_action :authenticate_admin!, except: :show

    def show
      @user = User.custom_find(params[:id])
      render json: @user, root: 'user', adapter: :json
    end

    def create
      @user = User.create(user_params)
      render json: @user, root: 'user', adapter: :json, location: user_url(@user)
    end

    def update
      @user = User.custom_find(params[:id])
      @user.update_attributes(user_params)
      render json: @user, root: 'user', adapter: :json
    end

    def destroy
      @user = User.custom_find(params[:id])
      @user.destroy
      render json: @user, root: 'user', adapter: :json
    end

    private

    def user_params
      params.require(:user).permit(
        :name,
        :username,
        :email,
        :encrypted_password,
        :authentication_token,
        sets: [:name, :privacy, :priority]
      )
    end
  end
end
