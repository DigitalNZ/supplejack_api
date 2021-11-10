# frozen_string_literal: true

module SupplejackApi
  class UsersController < SupplejackApplicationController
    include Pundit

    before_action :find_and_authorize_user, only: %i[show update destroy]
    respond_to :xml, :json
    rescue_from Pundit::NotAuthorizedError, with: :user_requires_admin_privileges

    def show
      respond_to do |format|
        format.json { render json: @user, root: 'user', adapter: :json }
        format.xml  { render_xml_with(@user, { serializer: UserSerializer }, 'user') }
      end
    end

    def create
      @user = User.create(user_params)
      authorize(@user)

      render json: @user, root: 'user', adapter: :json, location: user_url(@user)
    end

    def update
      @user.update(user_params)

      render json: @user, root: 'user', adapter: :json
    end

    def destroy
      @user.destroy

      render json: @user, root: 'user', adapter: :json
    end

    private

    def find_and_authorize_user
      @user = User.custom_find(params[:id])
      authorize(@user)
    end

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
