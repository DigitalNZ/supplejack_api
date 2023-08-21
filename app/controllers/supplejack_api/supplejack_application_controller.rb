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

      if current_user
        if current_user.over_limit?
          error_message = if RecordSchema.roles[current_user.role.to_sym].try(:anonymous)
                            I18n.t('users.anonymous_reached_limit')
                          else
                            I18n.t('users.reached_limit')
                          end
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
      token = request.headers['Authentication-Token'] || params[:api_key]

      return token if token

      SupplejackApi::User.find_or_create_by(name: 'anonymous', role: 'anonymous').authentication_token
    end

    def current_user
      @current_user ||= User.find_by_auth_token(current_auth_token)
    end

    def prevent_anonymous!
      return unless RecordSchema.roles[current_user.role.to_sym].try(:anonymous)

      render json: {
        errors: I18n.t('errors.prevent_anonymous')
      }, status: :forbidden
    end

    def render_error_with(message, code)
      render(json: { errors: message }, status: code)
    end

    def user_requires_admin_privileges
      render_error_with(I18n.t('errors.requires_admin_privileges'), :unauthorized)
    end

    def render_json_with(attributes)
      if SupplejackApi.config.global_response_field
        field = SupplejackApi.config.global_response_field
        attributes.merge!(meta: field[:value], meta_key: field[:key_name])
      end

      render attributes
    end

    def render_xml_with(resource, options, root)
      serializable_resource = ActiveModelSerializers::SerializableResource.new(resource, options).as_json

      if SupplejackApi.config.global_response_field
        field = SupplejackApi.config.global_response_field
        serializable_resource.merge!(field[:key_name] => field[:value])
      end

      # The double as_json is required to render the inner json object as json as well as the exterior object
      render xml: serializable_resource.as_json.to_xml(root: root)
    end
  end
end
