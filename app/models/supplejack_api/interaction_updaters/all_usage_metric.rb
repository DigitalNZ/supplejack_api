# frozen_string_literal: true

module SupplejackApi
  module InteractionUpdaters
    class AllUsageMetric
      BLACKLISTED_FIELDS = %i[_id created_at updated_at date record_field_value].freeze
      attr_reader :model

      def initialize
        # Slightly nonstandard model, so mock ActiveRecord interactions
        # that the InteractionMetricsWorker performs
        @model = OpenStruct.new(all: OpenStruct.new(delete_all: true))
      end

      # Sums up UsageMetrics entries for the day for all afacets and
      # writes it in UsageMetrics with record_field_value all
      def process(*)
        usage_metrics = SupplejackApi::UsageMetrics
                        .where(:record_field_value.ne => 'all')
                        .created_on(Time.now.utc.to_date)
        fields_to_update = SupplejackApi::UsageMetrics
                           .fields
                           .keys
                           .map(&:to_sym)
                           .reject { |field| BLACKLISTED_FIELDS.include? field }
        summed_usage_metrics_fields = usage_metrics.reduce({}) do |acc, el|
          fields_to_update.each_with_object(acc) do |field, accumulator|
            accumulator[field] = accumulator[field].to_i + el[field]
          end
        end
        all_metric = SupplejackApi::UsageMetrics.find_or_create_by(
          record_field_value: 'all',
          date: Time.now.utc.to_date
        ) do |m|
          m.record_field_value = 'all'
          m.date = Time.now.utc.to_date
        end

        all_metric.update(summed_usage_metrics_fields)
        true
      end
    end
  end
end
