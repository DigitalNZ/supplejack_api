# frozen_string_literal: true

module SupplejackApi
  class SupplejackApplicationController < ::ApplicationController
    before_action :authenticate_user!

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
      format = request.format.to_sym if %i[xml json rss].include?(request.format.try(:to_sym))

      render(format => { errors: error_message }, status: :forbidden) if error_message
    end

    def current_user
      @current_user ||= User.find_by_api_key(params[:api_key])
    end

    def authenticate_admin!
      return true if RecordSchema.roles[current_user.role.to_sym].try(:admin)
      render request.format.to_sym => {
        errors: 'You need Administrator privileges to perform this request'
      }, status: :forbidden
    end

    def authenticate_harvester!
      format = request.format.to_sym || :json
      return true if RecordSchema.roles[current_user.role.to_sym].try(:harvester)
      render format => {
        errors: "You need Harvester privileges to perform this request.\
        Your API key role must have the attribute { harvester: true }.\
        Check the available roles in your record_schema.rb file."
      }, status: :forbidden
    end

    def user_key_check!
      render request.format.to_sym => {
        errors: 'Mandatory parameter user_key missing'
      }, status: 400 unless params[:user_key]
    end

    def find_user_set
      user_set_id = params[:user_set_id] || params[:id]

      @user_set = if RecordSchema.roles[current_user.role.to_sym].try(:admin)
                    UserSet.custom_find(user_set_id)
                  else
                    current_user.user_sets.custom_find(user_set_id)
                  end

      render(json: { errors: "Set with id: #{params[:id]} was not found." }, status: :not_found) unless @user_set
    end
  end
end
