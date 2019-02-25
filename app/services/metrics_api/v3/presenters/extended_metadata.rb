# frozen_string_literal: true

module MetricsApi
  module V3
    module Presenters
      class ExtendedMetadata
        PRESENTERS_BASE = 'MetricsApi::V3::Presenters::'

        attr_reader :metrics, :start_date, :end_date

        def initialize(metrics, start_date, end_date)
          @metrics = metrics
          @start_date = start_date
          @end_date = end_date
        end

        def to_json
          binding.pry
          (start_date..end_date).map do |date|
            base = { date: date }

            todays_metrics = metrics.map do |metric|
              binding.pry
              relevent_models = metric[:models].select { |key| key == date }.values.first
              binding.pry
              presenter = (PRESENTERS_BASE + metric[:metric].camelize).constantize

              next { metric[:metric] => [] } if relevent_models.blank?

              { metric[:metric] => relevent_models.map(&presenter) }
            end

            binding.pry

            todays_metrics.each { |x| base.merge!(x) }

            binding.pry

            base
          end
        end

        def self.to_proc
          ->(models) { new(models).to_json }
        end
      end
    end
  end
end
