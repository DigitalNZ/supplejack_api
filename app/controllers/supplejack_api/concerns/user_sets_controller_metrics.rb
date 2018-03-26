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

          records = @user_set.set_items.each_with_object([]) do |item, array|
            next if item.record_id.nil?

            begin
              record = SupplejackApi.config.record_class.custom_find(item.record_id)
            rescue Mongoid::Errors::DocumentNotFound
              next
            end

            array.push(record_id: record.record_id, display_collection: record.display_collection)
          end

          SupplejackApi::RequestMetric.spawn(records, 'user_set_views')
        end

        def create_set_interaction
          return unless @user_set && log_request_for_metrics?
          return if @user_set.set_items.empty?

          begin
            record = SupplejackApi.config.record_class.custom_find(@user_set.set_items.first.record_id)
          rescue Mongoid::Errors::DocumentNotFound
            return
          end

          SupplejackApi::InteractionModels::Set.create(interaction_type: :creation, facet: record.display_collection)

          records = @user_set.set_items.each_with_object([]) do |item, array|
            next if item.record_id.nil?

            begin
              record = SupplejackApi.config.record_class.custom_find(item.record_id)
            rescue Mongoid::Errors::DocumentNotFound
              next
            end

            array.push(record_id: record.record_id, display_collection: record.display_collection)
          end

          SupplejackApi::RequestMetric.spawn(records, 'added_to_user_sets')
        end
      end
    end
  end
end
