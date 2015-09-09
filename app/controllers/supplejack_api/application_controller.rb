# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ApplicationController < ActionController::Base
    protect_from_forgery
  
    before_filter :authenticate_user!

    def authenticate_user!
      error_message = nil
  
      if params[:api_key].blank?
        error_message = I18n.t('users.blank_token')
      elsif current_user
        if current_user.over_limit?
          error_message = I18n.t('users.reached_limit')
        else
          current_user.update_tracked_fields(request)
          current_user.update_daily_activity(request)
          current_user.check_daily_requests
          current_user.save(validate: false)
        end
      else
        error_message = I18n.t('users.invalid_token')
      end
      
      format = :json
      format = request.format.to_sym if [:xml, :json, :rss].include?(request.format.try(:to_sym))
  
      if error_message
        render format => {errors: error_message}, status: :forbidden
      end
    end
  
    def current_user
      @current_user ||= User.find_by_api_key(params[:api_key])
    end

    def authenticate_admin!
      if RecordSchema.roles[current_user.role.to_sym].try(:admin)
        return true
      else
        render request.format.to_sym => {
          errors: "You need Administrator privileges to perform this request"
        }, status: :forbidden
        return false
      end
    end

    def find_user_set
      user_set_id = params[:user_set_id] || params[:id]

      if RecordSchema.roles[current_user.role.to_sym].try(:admin)
        @user_set = UserSet.custom_find(user_set_id)
      else
        @user_set = current_user.user_sets.custom_find(user_set_id)
      end
      
      unless @user_set
        render json: {errors: "Set with id: #{params[:id]} was not found."}, status: :not_found
      end
    end
  end
end
