# frozen_string_literal: true

module SupplejackApi
  class UsersController < SupplejackApplicationController
    include Pundit

    before_action :find_and_authorize_user, only: %i[show update destroy]
    respond_to :xml, :json
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def show
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

    def user_not_authorized
      render_error_with(I18n.t('errors.requires_admin_privileges'), :unauthorized)
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
