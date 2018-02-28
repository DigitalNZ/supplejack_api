# frozen_string_literal: true

module SupplejackApi
  module Admin
    class SessionsController < Devise::SessionsController
      protect_from_forgery with: :exception, prepend: true
      skip_before_action :authenticate_user!, raise: false
      protect_from_forgery prepend: true, with: :exception
      layout 'supplejack_api/application'

      def after_sign_in_path_for(resource)
        stored_location_for(resource) || admin_site_activities_path
      end

      def after_sign_out_path_for(_resource_or_scope)
        new_admin_user_session_path
      end
    end
  end
end
