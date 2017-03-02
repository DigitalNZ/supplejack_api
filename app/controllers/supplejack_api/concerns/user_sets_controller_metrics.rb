# frozen_string_literal: true
module SupplejackApi
  module Concerns
    module UserSetsControllerMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        after_action :create_set_record_view, only: :show
        after_action :create_set_interaction, only: :create

        def create_set_record_view
          return unless @user_set && log_request_for_metrics?

          SupplejackApi::InteractionModels::Record.create_user_set(@user_set)
        end

        def create_set_interaction
          return unless @user_set && log_request_for_metrics?
          return if @user_set.set_items.empty?

          record = SupplejackApi::Record.custom_find(@user_set.set_items.first.record_id)
          SupplejackApi::InteractionModels::Set.create(interaction_type: :creation, facet: record.display_collection)
        end
      end
    end
  end
end
