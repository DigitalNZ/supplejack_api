module SupplejackApi
  module Concerns
    module RecordsControllerMetrics
      extend ActiveSupport::Concern
      include IgnoreMetrics

      included do
        after_action :log_search, only: :index
        after_action :log_record_view, only: :show

        def log_search
          return unless @search.valid? && log_request_for_metrics?

          SupplejackApi::InteractionModels::Record.create_search(@search)
        end

        def log_record_view
          return unless log_request_for_metrics?

          SupplejackApi::InteractionModels::Record.create_find(@record)
        end
      end
    end
  end
end
