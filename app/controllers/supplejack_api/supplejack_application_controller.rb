# frozen_string_literal: true

module SupplejackApi
  class SupplejackApplicationController < ::ApplicationController
    before_action :authenticate_user!

    rescue_from ActionController::ParameterMissing do |error|
      render request.format.to_sym => { errors: I18n.t('errors.param_missing', param: error.param.to_s) },
             status: :bad_request
    end

    rescue_from Timeout::Error do |_exception|
      render request.format.to_sym => { errors: [I18n.t('errors.time_out')] }, status: :request_timeout
    end

    rescue_from Errno::ECONNREFUSED, Errno::ECONNRESET do |_exception|
      render request.format.to_sym => { errors: [I18n.t('errors.solr_unavailable')] },
             status: :service_unavailable
    end

    rescue_from Mongoid::Errors::DocumentNotFound do |_exception|
      render request.format.to_sym => { errors: I18n.t('errors.record_not_found', id: params[:id]) }, status: :not_found
    end

    def authenticate_user!
      error_message = nil

      if current_auth_token.blank?
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

    def current_auth_token
      Rails.logger.info "Authentication-Token : #{request.headers}"
      @current_auth_token = request.headers['Authentication-Token'] || params[:api_key]
    end

    def current_user
      @current_user ||= User.find_by_auth_token(current_auth_token)
    end

    def current_story_user
      @current_story_user ||= User.find_by_auth_token(params[:user_key])
    end

    def authenticate_admin!
      return true if RecordSchema.roles[current_user.role.to_sym].try(:admin)

      render request.format.to_sym => {
        errors: I18n.t('errors.requires_admin_privileges')
      }, status: :forbidden
    end

    def authenticate_harvester!
      format = request.format.to_sym || :json
      return true if RecordSchema.roles[current_user.role.to_sym].try(:harvester)

      render format => {
        errors: I18n.t('errors.requires_harvest_privileges')
      }, status: :forbidden
    end

    def story_user_check
      if params[:user_key]
        render_error_with(I18n.t('errors.user_not_found', key: params[:user_key]), :not_found) unless current_story_user
      else
        render_error_with(I18n.t('errors.user_key_missing'), :bad_request)
      end
    end

    def find_user_set
      id = params[:user_set_id] || params[:id]

      @user_set = if RecordSchema.roles[current_user.role.to_sym].try(:admin)
                    UserSet.custom_find(id)
                  else
                    current_user.user_sets.custom_find(id)
                  end

      render(json: { errors: I18n.t('errors.user_set_not_found', id: id) }, status: :not_found) unless @user_set
    end

    def render_error_with(message, code)
      render(json: { errors: message }, status: code)
    end
  end
end
