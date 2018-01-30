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

          SupplejackApi::InteractionModels::Record.create_search(@search)

          @search.records.each do |record|
            SupplejackApi::RecordMetric.spawn(record.record_id, :appeared_in_searches, record.content_partner)
          end
        end

        def log_record_view
          return unless @record && log_request_for_metrics?

          SupplejackApi::InteractionModels::Record.create_find(@record)

          SupplejackApi::RecordMetric.spawn(@record.record_id, :page_views, @record.content_partner)
        end

        def log_source_clickthrough
          return unless @record

          SupplejackApi::InteractionModels::SourceClickthrough.create(facet: @record.display_collection)

          SupplejackApi::RecordMetric.spawn(@record.record_id, :source_clickthroughs, @record.content_partner)
        end
      end
    end
  end
end
