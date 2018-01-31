# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module StoriesControllerMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        after_action :create_story_record_views, only: :show

        def create_story_record_views
          return unless @api_response[:payload] && log_request_for_metrics?

          @api_response[:payload][:contents].each do |record|
            SupplejackApi::RecordMetric.spawn(record[:record_id], :user_story_views, record[:content][:content_partner])
          end
        end
      end
    end
  end
end
