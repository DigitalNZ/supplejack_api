# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class BaseController < SupplejackApplicationController
      include Pundit
      rescue_from Pundit::NotAuthorizedError, with: :user_requires_harvest_privileges

      respond_to :json

      before_action :authenticate_harvester!

      def authenticate_harvester!
        authorize(current_user, policy_class: SupplejackApi::Harvester::HarvesterPolicy)
      end

      def user_requires_harvest_privileges
        render_error_with(I18n.t('errors.requires_harvest_privileges'), :unauthorized)
      end
    end
  end
end
