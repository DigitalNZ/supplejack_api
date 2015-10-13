module SupplejackApi
  module Concerns
    module UserSetsControllerMetrics
      extend ActiveSupport::Concern

      included do
        before_action :set_existing_user_set_items, only: :update
        after_action :create_set_interaction, only: :update
        after_action :create_set_record_view, only: :show

        def create_set_interaction
          return unless params[:set].key? :records

          record_ids = params[:set][:records].map{|x| x[:record_id]}
          new_record_ids = record_ids.reject{|id| existing_user_set_items.any?{|set_item| set_item.record_id.to_s == id}}
          display_collections = SupplejackApi::Record.find_multiple(new_record_ids).map(&:display_collection)

          display_collections.each{|dc| InteractionModels::Set.create(interaction_type: :creation, facet: dc)}
        end

        def create_set_record_view
          return unless @user_set

          SupplejackApi::InteractionModels::Record.create_user_set(
            @user_set, 
            params[:request_logger_field]
          ) if params[:request_logger]
        end

        def set_existing_user_set_items
          return unless @user_set

          @existing_user_set_items = @user_set.set_items.dup
        end
      end
    end
  end
end
