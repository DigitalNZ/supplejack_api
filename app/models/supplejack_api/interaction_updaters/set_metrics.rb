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
          all_metric = SupplejackApi::UsageMetrics.find_or_create_by(
            date: Date.current,
            record_field_value: 'all'
          ) do |um|
            um.date = Date.current
            um.record_field_value = 'all'
          end

          records_added = set_interactions.count{|x| x.facet == facet} 
          [all_metric, metric].each do |m|
            m.records_added_to_user_sets += records_added
            m.save!
          end
        end

        true
      end
    end
  end
end
