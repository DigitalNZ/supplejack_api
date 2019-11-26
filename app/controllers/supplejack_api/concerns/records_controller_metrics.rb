# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module RecordsControllerMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        after_action :log_search, only: :index
        after_action :log_record_view, only: :show
        after_action :log_source_clickthrough, only: :source

        def log_search
          return unless @search.valid? && log_request_for_metrics?

          SupplejackApi::RequestMetric.spawn(
            @search.records.map do |record|
              { record_id: record.record_id, display_collection: record.display_collection }
            end,
            'appeared_in_searches'
          )
        end

        def log_record_view
          return unless @record && log_request_for_metrics?

          SupplejackApi::RequestMetric.spawn(
            [
              { record_id: @record.record_id, display_collection: @record.display_collection }
            ],
            'page_views'
          )
        end

        def log_source_clickthrough
          return unless @record && log_request_for_metrics?

          SupplejackApi::RequestMetric.spawn(
            [
              { record_id: @record.record_id, display_collection: @record.display_collection }
            ],
            'source_clickthroughs'
          )
        end
      end
    end
  end
end
