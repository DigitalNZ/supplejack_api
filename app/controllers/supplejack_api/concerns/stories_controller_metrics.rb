# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module StoriesControllerMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        after_action :create_story_record_views, only: :show

        def create_story_record_views
          return unless log_request_for_metrics?

          payload = JSON.parse(response.body)
          log = payload['contents']&.map do |record|
            { record_id: record['record_id'], display_collection: record['content']['display_collection'] }
          end

          SupplejackApi::RequestMetric.spawn(log, 'user_story_views') if log
        end
      end
    end
  end
end
