# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UsersController < ApplicationController
    
    respond_to  :xml, :json
    before_filter :authenticate_admin!, except: :show
    
    def show
      @user = User.custom_find(params[:id])
      respond_with @user, serializer: UserSerializer
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
