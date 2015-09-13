module MetricsApi
  module V1
    module Presenters
      class ApiResponse
        attr_reader :mi, :smo

        def initialize(metrics_information, sub_metric_objects)
          @mi = metrics_information
          @smo = sub_metric_objects
        end

        def to_json
          required_fields = {
            day: mi[:day].to_s,
            total_active_records: mi[:total_active_records],
            total_new_records: mi[:total_new_records]
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
    end
  end
end
