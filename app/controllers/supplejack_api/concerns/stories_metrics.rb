# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module StoriesMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        after_action :create_story_record_views, only: :show
        after_action :create_story_interaction, only: :create

        def create_story_record_views
          return unless @api_response[:payload] && log_request_for_metrics?

          @api_response[:payload][:contents].each do |record|
            SupplejackApi::RecordMetric.spawn(record[:record_id], :user_story_views, record[:content][:content_partner])
          end
        end

        def create_story_interaction
          return unless @api_response[:payload] && log_request_for_metrics?

          record = @api_response[:payload]

          SupplejackApi::RecordMetric.spawn(record[:record_id], :added_to_user_stories, record[:content][:content_partner])
        end
      end
    end
  end
end
