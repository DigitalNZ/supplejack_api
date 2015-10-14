module SupplejackApi
  module Concerns
    module SetItemsControllerMetrics
      extend ActiveSupport::Concern

      included do
        before_action :create_set_interaction, only: :create

        def create_set_interaction
          record = SupplejackApi::Record.custom_find(params[:record][:record_id])
          SupplejackApi::InteractionModels::Set.create(interaction_type: :creation, facet: record.display_collection)
        end
      end
    end
  end
end
