module SupplejackApi
  module Concerns
    module SetItemsControllerMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        before_action :create_set_interaction, only: :create

        def create_set_interaction
          return unless log_request_for_metrics?

          record = SupplejackApi::Record.custom_find(params[:record][:record_id])
          SupplejackApi::InteractionModels::Set.create(interaction_type: :creation, facet: record.display_collection)
        end
      end
    end
  end
end
