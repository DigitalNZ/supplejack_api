module SupplejackApi
  module Concerns
    module UserSetsControllerMetrics
      extend ActiveSupport::Concern

      included do
        after_action :create_set_record_view, only: :show

        def create_set_record_view
          return unless @user_set

          SupplejackApi::InteractionModels::Record.create_user_set(
            @user_set, 
            params[:request_logger_field]
          ) if params[:request_logger]
        end
      end
    end
  end
end
