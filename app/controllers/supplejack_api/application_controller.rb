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
        render format => {:errors => error_message}, :status => :forbidden
      end
    end
  
    def current_user
      @current_user ||= User.find_by_api_key(params[:api_key])
    end
  end
end
