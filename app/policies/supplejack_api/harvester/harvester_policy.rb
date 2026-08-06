# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class HarvesterPolicy
      attr_reader :user

      def initialize(user, _policy_class)
        @user = user
      end

      def harvester?
        role.try(:harvester)
      end

      # Read only access to the harvester API. Full harvester roles imply read access.
      def harvester_read_only?
        harvester? || role.try(:harvester_read_only)
      end

      alias index?   harvester?
      alias show?    harvester?
      alias create?  harvester?
      alias update?  harvester?
      alias destroy? harvester?
      alias delete?  harvester?

      # custom harvester actions
      alias flush?              harvester?
      alias reindex?            harvester?
      alias create_batch?       harvester?
      alias link_check_records? harvester?

      private

      def role
        RecordSchema.roles[@user.role.to_sym]
      end
    end
  end
end
