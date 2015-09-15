module MetricsApi
  module V3
    module Presenters
      # Takes in metrics information and a list of sub metrics
      # (ie usage, display_collection metrics) and stitches them
      # together in the format the API uses
      class ApiResponse
        attr_reader :mi, :smo

        # @param metrics_information [MetricsInformation] top level information about a day of metrics,
        #   actual argument is a hash containing the +MetricsInformation+ fields, it gets parsed into
        #   a +MetricsInformation+ object
        # @param sub_metric_objects [Array<Hash>] list of sub metrics to merge into metric hash.
        #   It is a hash with the keys, *metric* => metric_name, *models* => list of metric models 
        #   for this metric
        def initialize(metrics_information, sub_metric_objects)
          @mi = MetricsInformation.new(metrics_information)
          @smo = sub_metric_objects
        end

        def to_json
          required_fields = {
            day: mi.day.to_s,
            total_active_records: mi.total_active_records,
            total_new_records: mi.total_new_records
          }

          smo.each do |x|
            required_fields.merge!({x[:metric] => x[:models]})
          end

          required_fields
        end

        def self.to_proc
          ->(metric_information){self.new(metric_information.first, metric_information.last).to_json}
        end
      end

      # @abstract
      # Container for metrics_information arguments
      class MetricsInformation
        attr_reader :day, :total_active_records, :total_new_records

        def initialize(metrics_information)
          @day = metrics_information[:day]
          @total_active_records = metrics_information[:total_active_records]
          @total_new_records = metrics_information[:total_new_records]
        end
      end
    end
  end
end
