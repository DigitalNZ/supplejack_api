# frozen_string_literal: true

module MetricsApi
  module V3
    module Endpoints
      module Helpers
        def parse_date_param(date_param)
          return nil if date_param.blank?

          Date.parse(date_param)
        end
      end
    end
  end
end
