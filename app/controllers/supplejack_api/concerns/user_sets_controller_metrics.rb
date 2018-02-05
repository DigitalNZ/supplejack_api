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

          @user_set.set_items.each do |item|
            next if item.record_id.nil?
            record = SupplejackApi.config.record_class.custom_find(item.record_id)
            SupplejackApi::RecordMetric.spawn(record.record_id, :user_set_views, record.content_partner)
          end
        end

        def create_set_interaction
          return unless @user_set && log_request_for_metrics?
          return if @user_set.set_items.empty?

          record = SupplejackApi.config.record_class.custom_find(@user_set.set_items.first.record_id)
          SupplejackApi::InteractionModels::Set.create(interaction_type: :creation, facet: record.display_collection)

          @user_set.set_items.each do |item|
            next if item.record_id.nil?
            record = SupplejackApi.config.record_class.custom_find(item.record_id)
            SupplejackApi::RecordMetric.spawn(record.record_id, :added_to_user_sets, record.content_partner)
          end
        end
      end
    end
  end
end
