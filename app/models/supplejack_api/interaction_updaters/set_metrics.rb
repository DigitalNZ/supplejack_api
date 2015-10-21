module SupplejackApi
  module InteractionUpdaters
    class SetMetrics

      attr_reader :model

      def initialize
        @model = SupplejackApi::InteractionModels::Set
      end

      def process(set_interactions)
        unique_facets = set_interactions.map(&:facet).uniq

        unique_facets.each do |facet|
          metric = SupplejackApi::UsageMetrics.find_or_create_by(
            date: Date.current,
            record_field_value: facet
          ) do |um|
            um.date = Date.current
            um.record_field_value = facet
          end

          metric.records_added_to_user_sets += set_interactions.count{|x| x.facet == facet}
          metric.save!
        end

        true
      end
    end
  end
end
