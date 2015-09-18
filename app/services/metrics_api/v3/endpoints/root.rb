module MetricsApi
  module V3
    module Endpoints
      class Root
        attr_reader :start_date, :end_date

        def initialize(params)
          @start_date = params[:start_date] || Date.yesterday
          @end_date = params[:end_date] || Date.current
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

        private

        def parse_date(date_string)
          return nil unless date_string.present?

          Date.parse(date_string)
        end
      end
    end
  end
end
