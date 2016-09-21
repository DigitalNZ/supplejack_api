# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Admin
    class SessionsController < Devise::SessionsController
      layout 'supplejack_api/application'

      skip_before_filter :authenticate_user!

      def after_sign_in_path_for(resource)
        stored_location_for(resource) || admin_users_path
      end

      def after_sign_out_path_for(_resource_or_scope)
        new_admin_user_session_path
      end
    end
  end
end
