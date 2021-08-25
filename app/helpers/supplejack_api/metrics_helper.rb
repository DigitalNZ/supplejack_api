# frozen_string_literal: true

module SupplejackApi
  module MetricsHelper
    def start_date_with(value)
      return Time.now.utc.yesterday if value.blank?

      Date.parse(value)
    end
    module_function :start_date_with

    def end_date_with(value)
      return Time.now.utc.to_date if value.blank?

      Date.parse(value)
    end
    module_function :end_date_with
  end
end
