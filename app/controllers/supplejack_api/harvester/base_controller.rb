# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class BaseController < SupplejackApplicationController
      include Pundit::Authorization
      rescue_from Pundit::NotAuthorizedError, with: :user_requires_harvest_privileges

      respond_to :json

      before_action :authenticate_harvester!

      # Actions listed here are authorized against HarvesterPolicy#harvester_read_only? instead of the
      # action's own predicate, which lets read only roles through. Opt in per controller: most harvester
      # endpoints either write, or read data (eg. user API keys) that a read only role has no business seeing.
      class_attribute :read_only_action_names, instance_writer: false, default: []

      def self.read_only_actions(*actions)
        self.read_only_action_names = actions.map(&:to_s)
      end

      def authenticate_harvester!
        authorize(current_user, policy_query, policy_class: SupplejackApi::Harvester::HarvesterPolicy)
      end

      def user_requires_harvest_privileges
        render_error_with(I18n.t('errors.requires_harvest_privileges'), :unauthorized)
      end

      private

      def policy_query
        :harvester_read_only? if read_only_action_names.include?(action_name)
      end
    end
  end
end
