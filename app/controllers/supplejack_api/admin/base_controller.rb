# frozen_string_literal: true

module SupplejackApi
  module Admin
    class BaseController < SupplejackApplicationController
      skip_before_action :authenticate_user!, raise: false
      before_action :authenticate_admin_user!
      before_action :restrict_to_admin_users!

      def restrict_to_admin_users!
        return if current_admin_user.admin?

        sign_out
        redirect_to new_admin_user_session_path, alert: t('admin.not_a_admin')
      end
    end
  end
end
