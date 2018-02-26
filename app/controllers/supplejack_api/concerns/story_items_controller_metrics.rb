# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module StoryItemsControllerMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        after_action :create_story_item_interaction, only: :create

        def create_story_item_interaction
          return unless @api_response[:payload] && log_request_for_metrics?

          record = @api_response[:payload]

          return if record[:record_id].blank?

          SupplejackApi::RecordMetric.spawn(record[:record_id],
                                            :added_to_user_stories,
                                            record[:content][:display_collection])
        end
      end
    end
  end
end
