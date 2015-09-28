module MetricsApi
  module V3
    module Endpoints
      class Root
        include Helpers
        attr_reader :start_date, :end_date

        def initialize(params)
          @start_date = parse_date_param(params[:start_date]) || Date.yesterday
          @end_date = parse_date_param(params[:end_date]) || Date.yesterday
        end

        def call
          models = SupplejackApi::DailyItemMetric.created_between(start_date, end_date)

          if models.empty?
            return {
              exception: {
                message: 'No metrics for the date range requested',
                status: 404
              }
            }
          end

          models.map(&MetricsApi::V3::Presenters::DailyMetricsMetadata)
        end
      end
    end
  end
end
