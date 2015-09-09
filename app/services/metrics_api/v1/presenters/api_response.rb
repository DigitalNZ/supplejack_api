module MetricsApi
  module V1
    module Presenters
      class ApiResponse

        def initialize(metrics_information, sub_metric_objects)
          @mi = metrics_information
          @smo = sub_metric_objects
        end

        def to_json
          required_fields = {
            day: @mi[:day],
            total_active_records: @mi[:total_active_records],
            total_new_records: @mi[:total_new_records]
          }

          required_fields.merge(@smo)
        end

        def self.to_proc
          ->(metric_information, sub_objects){self.new(metric_information, sub_objects).to_json}
        end
      end
    end
  end
end
