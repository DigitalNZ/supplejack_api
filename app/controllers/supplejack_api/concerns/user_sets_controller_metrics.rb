module SupplejackApi
  module Concerns
    module UserSetsControllerMetrics
      extend ActiveSupport::Concern

      included do
        after_action :create_set_record_view, only: :show
        after_action :create_set_interaction, only: :create

        def create_set_record_view
          return unless @user_set

          SupplejackApi::InteractionModels::Record.create_user_set(
            @user_set, 
            params[:request_logger_field]
          ) if params[:request_logger]
        end

        def create_set_interaction
          return unless @user_set

          record = SupplejackApi::Record.custom_find(@user_set.set_items.first.record_id)
          SupplejackApi::InteractionModels::Set.create(interaction_type: :creation, facet: record.display_collection)
        end
      end
    end
  end
end
