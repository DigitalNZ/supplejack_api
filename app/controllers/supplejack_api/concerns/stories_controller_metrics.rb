# frozen_string_literal: true

# module SupplejackApi
#   module Concerns
#     module StoriesControllerMetrics
#       extend ActiveSupport::Concern
#       include IgnoreMetrics

#       included do
#         after_action :create_story_record_views, only: :show

#         def create_story_record_views
#           return unless @api_response[:payload] && log_request_for_metrics?

#           SupplejackApi::RequestMetric.spawn(
#             @api_response[:payload][:contents].map do |record|
#               { record_id: record[:record_id], display_collection: record[:content][:display_collection] }
#             end,
#             'user_story_views'
#           )
#         end
#       end
#     end
#   end
# end
