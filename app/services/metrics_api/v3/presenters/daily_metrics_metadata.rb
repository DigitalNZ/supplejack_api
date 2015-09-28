module MetricsApi
  module V3
    module Presenters
      # Presents a DailyItemMetric into a daily metric metadata response object
      class DailyMetricsMetadata
        attr_reader :daily_metric

        # @param metrics_information [MetricsInformation] top level information about a day of metrics,
        #   actual argument is a hash containing the +MetricsInformation+ fields, it gets parsed into
        #   a +MetricsInformation+ object
        def initialize(daily_metric)
          @daily_metric = MetricsInformation.new(daily_metric)
        end

        def to_json
          {
            day: daily_metric.day.to_s,
            total_active_records: daily_metric.total_active_records,
            total_new_records: daily_metric.total_new_records
          }
        end

        def self.to_proc
          ->(daily_metric){self.new(daily_metric).to_json}
        end
      end

      # @abstract
      # Container for metrics_information arguments
      class MetricsInformation
        attr_reader :day, :total_active_records, :total_new_records

        def initialize(metrics_information)
          @day = metrics_information.day
          @total_active_records = metrics_information.total_active_records
          @total_new_records = metrics_information.total_new_records
        end
      end
    end
  end
end
