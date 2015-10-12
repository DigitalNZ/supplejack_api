module SupplejackApi
  module InteractionUpdaters
    class UsageMetrics
      attr_reader :model

      def initialize
        @model = SupplejackApi::InteractionModels::Record
      end

      def process(request_logs)
        search_counts = build_hash_for(request_logs, "search")
        get_counts = build_hash_for(request_logs, "get")
        user_set_counts = build_hash_for(request_logs, "user_set")

        unique_facets = (search_counts.keys + get_counts.keys + user_set_counts.keys).uniq

        # Creating metrics for each primary collection
        unique_facets.each do |facet|
          process_facet(facet, search_counts, get_counts, user_set_counts)
        end

        update_or_create_all_facet(search_counts, get_counts, user_set_counts)

        true
      end

      private

      def process_facet(facet, search_counts, get_counts, user_set_counts)
        usage_metric_entry = SupplejackApi::UsageMetrics.find_or_create_by(
          :day => Date.current, 
          :record_field_value => facet
        ) do |metric|
          metric.day = Date.current
          metric.record_field_value = facet
        end

        # set everything to default value of 0 if no value is present, makes following code simpler
        [search_counts, get_counts, user_set_counts].each do |x|
          x[facet] = 0 unless x[facet]
        end

        searches = usage_metric_entry.searches + search_counts[facet]
        gets = usage_metric_entry.gets + get_counts[facet]
        user_set_views = usage_metric_entry.user_set_views + user_set_counts[facet]

        total = searches + gets + user_set_views

        usage_metric_entry.update(
          searches: searches,
          gets: gets,
          user_set_views: user_set_views,
          total: total
        )
      end

      def update_or_create_all_facet(search_counts, get_counts, user_set_counts)
        all_metric_entry = SupplejackApi::UsageMetrics.find_or_create_by(record_field_value: 'all') do |entry|
          entry.record_field_value = 'all'
          entry.day = Date.current
        end

        search_counts = search_counts.values.sum
        get_counts = get_counts.values.sum
        user_set_counts = user_set_counts.values.sum

        all_metric_entry.searches += search_counts
        all_metric_entry.gets += get_counts
        all_metric_entry.user_set_views += user_set_counts
        all_metric_entry.total += search_counts + get_counts + user_set_counts

        all_metric_entry.save
      end

      def build_hash_for(request_logs, request_type)
        filtered_request_logs = request_logs.select{|rl| rl.request_type == request_type}
        counts_by_facet = {}

        filtered_request_logs.each do |rl|
          next unless rl.log_values.present?

          rl.log_values.each do |facet|
            counts_by_facet[facet] = 0 unless counts_by_facet.key? facet
            counts_by_facet[facet] += 1
          end
        end

        counts_by_facet
      end
    end
  end
end
