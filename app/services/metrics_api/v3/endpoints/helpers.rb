# frozen_string_literal: true
module MetricsApi
  module V3
    module Endpoints
      module Helpers
        def parse_date_param(date_param)
          return nil unless date_param.present?

          Date.parse(date_param)
        end
      end
    end
  end
end
