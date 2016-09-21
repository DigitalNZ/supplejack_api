# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Admin
    class BaseController < ApplicationController
      skip_before_filter :authenticate_user!
      before_filter :authenticate_admin_user!
      before_filter :restrict_to_admin_users!

      def restrict_to_admin_users!
        return if current_admin_user.admin?

        sign_out
        redirect_to new_admin_user_session_path, alert: t('admin.not_a_admin')
      end
    end
  end
end
