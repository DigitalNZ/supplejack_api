# frozen_string_literal: true

module SupplejackApi
  class DailyMetricsWorker
    include Sidekiq::Worker
    sidekiq_options queue: 'critical', retry: 1

    attr_reader :primary_key, :secondary_keys

    def initialize
      # configuration for metrics logging
      # the primary_key is what the records get grouped on
      # the secondary_keys are the fields counted, they must be multivalue fields
      # if the secondary_keys are changed the FacetedMetrics model must be updated
      # so that the field names match the new secondary_key names (the name must have '_counts' appended to it)
      @primary_key = 'display_collection'
      @secondary_keys = %w[
        category
        copyright
      ]
    end

    def perform
      call
    end

    # Uses +SupplejackApi::RecordSearch+ to query the API for metrics information
    # Metrics are grouped by the +@primary_key+ variable set in the constructor
    # Metric information extracted from each record is determined by the +@secondary_keys+ variable
    #
    # The output of this worker is a +SupplejackApi::DailyItemMetric+ to represent metrics about the
    # overall system and one +SupplejackApi::FacetedMetrics+ for each set of records grouped by the +@primary_key+
    def call
      facets = FacetsHelper.get_list_of_facet_values(primary_key)
      partial_facets_data = facets.map(&method(:retrieve_facet_data))
      full_facets_data = update_total_new_records(partial_facets_data)
      create_metrics_records(full_facets_data)
      create_daily_metrics
    end

    private

    def retrieve_facet_data(facet)
      s = RecordSearch.new(facets: secondary_keys.join(','), and: { primary_key.to_sym => facet })
      facet_key_mappings = secondary_keys.reduce({}) { |a, e| a.merge(e.to_sym => custom_key_to_field_name(e)) }
      facet_metadata = Hash[s.facets_hash.map { |k, v| [facet_key_mappings[k] || k, v] }]

      {
        name: facet,
        date: Time.now.utc.to_date,
        total_active_records: s.total,
        total_new_records: 0
      }.merge(facet_metadata)
    end

    def update_total_new_records(facets)
      facets = facets.dup
      records = SupplejackApi.config.record_class.active.created_on(Time.now.utc.to_date)
      counts_grouped_by_primary_key = records.group_by(&primary_key.to_sym).map { |k, v| [k, v.length] }

      counts_grouped_by_primary_key.each do |primary_key, count|
        facet_to_update = facets.find { |x| x[:name] == primary_key }

        next if facet_to_update.blank?

        facet_to_update[:total_new_records] = count
      end

      facets
    end

    def create_metrics_records(facets)
      merge_block = lambda do |a, e|
        a.merge(e) { |_, oldVal, newVal| oldVal + newVal }
      end

      active_records = SupplejackApi.config.record_class.active
      total_records = active_records.count
      total_new_records = active_records.created_on(Time.now.utc.to_date).count
      total_copyright_counts = facets.map { |x| x[:copyright_counts] }.reduce({}, &merge_block)
      total_category_counts = facets.map { |x| x[:category_counts] }.reduce({}, &merge_block)

      FacetedMetrics.create(
        name: 'all',
        date: Time.now.utc.to_date,
        total_active_records: total_records,
        total_new_records: total_new_records,
        copyright_counts: total_copyright_counts,
        category_counts: total_category_counts
      )

      facets.each { |x| FacetedMetrics.create(x) }
    end

    def create_daily_metrics
      public_user_sets_count = SupplejackApi::UserSet.publicly_viewable.excluding_favorites.count

      DailyMetrics.create(
        date: Time.now.utc.to_date,
        total_public_sets: public_user_sets_count
      )
    end

    def custom_key_to_field_name(key)
      "#{key}_counts".to_sym
    end
  end
end
