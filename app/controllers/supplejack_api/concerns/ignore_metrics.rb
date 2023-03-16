# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module IgnoreMetrics
      extend ActiveSupport::Concern

      included do
        def log_request_for_metrics?
          # (!params.key? :ignore_metrics) && request.human?
        end
      end
    end
  end
end
