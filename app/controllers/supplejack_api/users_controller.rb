require_dependency 'supplejack_api/application_controller'

module SupplejackApi
  class UsersController < ApplicationController
    
    respond_to  :xml, :json
    before_filter :authenticate_admin!, except: :show
    
    def show
      # @user = User.custom_find(params[:id])
      # respond_with @user, serializer: UserSerializer
    end
    
    # def create
    #   @user = User.create(user_params)
    #   respond_with @user, location: user_url(@user), serializer: UserSerializer
    # end
  
    # def update
    #   @user = User.custom_find(params[:id])
    #   @user.update_attributes(user_params)
    #   render json: @user, serializer: UserSerializer
    # end
  
    # def destroy
    #   @user = User.custom_find(params[:id])
    #   @user.destroy
    #   respond_with @user
    # end
  
    # private
  
    # def user_params
    #   params.require(:user).permit(:name, :username, :email, :encrypted_password, :sets, :authentication_token)
    # end
  end

end
