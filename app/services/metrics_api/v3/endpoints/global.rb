# frozen_string_literal: true
module MetricsApi
  module V3
    module Endpoints
      # Global endpoint. Returns a list of presented DailyMetrics models
      class Global
        include Helpers

        attr_reader :start_date, :end_date

        # All endpoints take in a params hash, this endpoint has no params however
        def initialize(params)
          @start_date = parse_date_param(params[:start_date]) || Time.zone.yesterday
          @end_date = parse_date_param(params[:end_date]) || Time.zone.today
        end

        # TODO: Better way of collecting display_collection names
        def call
          metrics = SupplejackApi::DailyMetrics.created_between(start_date, end_date)

          metrics.map(&MetricsApi::V3::Presenters::DailyMetric)
        end
      end
    end
  end
end
