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

        def to_json(*_args)
          (start_date..end_date).map do |date|
            base = { date: date }

            todays_metrics = metrics.map do |metric|
              relevant_models = metric[:models].select { |key| key == date }.values.first
              presenter = (PRESENTERS_BASE + metric[:metric].camelize).constantize

              next { metric[:metric] => [] } if relevant_models.blank?

              if metric[:metric] == 'top_records'
                { metric[:metric] => relevant_models.map(&presenter).reduce({}, :merge) }
              else
                { metric[:metric] => relevant_models.map(&presenter) }
              end
            end

            todays_metrics.each { |x| base.merge!(x) }

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
