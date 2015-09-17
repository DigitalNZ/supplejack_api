module MetricsApi
  module V3
    module Endpoints
      class Root
        attr_reader :start_date, :end_date

        def initialize(params)
          @start_date = params[:start_date] || Date.current
          @end_date = params[:end_date] || Date.current
        end

        def call
          SupplejackApi::DailyItemMetric
            .created_between(start_date, end_date)
            .map(&MetricsApi::V3::Presenters::DailyMetricsMetadata)
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
