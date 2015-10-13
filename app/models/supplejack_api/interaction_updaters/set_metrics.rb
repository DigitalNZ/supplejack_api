module SupplejackApi
  module InteractionUpdaters
    class SetMetrics

      def initialize
        @model = SupplejackApi::InteractionModels::Set
      end

      def process(set_interactions)
        unique_facets = set_interactions.map(&:facet).uniq

        unique_facets.each do |facet|
          metric = SupplejackApi::SetMetrics.find_or_create_by(
            day: Date.current,
            facet: facet
          ) do |sm|
            sm.day = Date.current
            sm.facet = facet
          end

          metric.total_records_added += set_interactions.count{|x| x.facet == facet}
          metric.save!
        end
      end
    end
  end
end
