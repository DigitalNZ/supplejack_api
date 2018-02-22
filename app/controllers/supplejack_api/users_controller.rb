# frozen_string_literal: true



module SupplejackApi
  class UsersController < ApplicationController
    respond_to :xml, :json
    before_action :authenticate_admin!

    def show
      @user = User.custom_find(params[:id])
      respond_to do |format|
        format.json { render json: @user, root: 'user', adapter: :json }
        format.xml  do
          options = { serializer: UserSerializer }
          serializable_resource = ActiveModelSerializers::SerializableResource.new(@user, options)

          render xml: serializable_resource.as_json.to_xml(root: 'user')
        end
      end
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
        sets: %i[name privacy priority]
      ).to_h
    end
  end
end
