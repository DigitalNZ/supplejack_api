module SupplejackApi
  module Concerns
    module RecordsControllerMetrics
      extend ActiveSupport::Concern

      included do
        after_action :log_search, only: :index
        after_action :log_record_view, only: :show

        def log_search
          return unless @search.valid?

          SupplejackApi::InteractionModels::Record.create_search(
            @search, 
            params[:request_logger_field]
          ) if params[:request_logger]
        end

        def log_record_view
          SupplejackApi::InteractionModels::Record.create_find(
            @record, 
            params[:request_logger_field]
          ) if params[:request_logger]
        end
      end
    end
  end
end
