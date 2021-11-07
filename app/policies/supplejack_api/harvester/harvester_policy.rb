# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class HarvesterPolicy
      attr_reader :user

      def initialize(user, _foo)
        @user = user
      end

      def harvester?
        RecordSchema.roles[@user.role.to_sym].try(:harvester)
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
      alias link_check_records? harvester?
    end
  end
end
