# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class DailyItemMetricsWorker

    attr_reader :primary_key, :secondary_keys
    @queue = :daily_item_metrics

    def initialize
      # configuration for metrics logging
      # the primary_key is what the records get grouped on
      # the secondary_keys are the fields counted, they must be multivalue fields
      # if the secondary_keys are changed the FacetedMetrics model must be updated
      # so that the field names match the new secondary_key names (the name must have '_counts' appended to it)
      @primary_key = 'display_collection'
      @secondary_keys = [
        'category',
        'copyright'
      ]
    end

    def self.perform
      self.new.call
    end

    # Uses +SupplejackApi::RecordSearch+ to query the API for metrics information
    # Metrics are grouped by the +@primary_key+ variable set in the constructor
    # Metric information extracted from each record is determined by the +@secondary_keys+ variable
    #
    # The output of this worker is a +SupplejackApi::DailyItemMetric+ to represent metrics about the 
    # overall system and one +SupplejackApi::FacetedMetrics+ for each set of records grouped by the +@primary_key+
    def call
      facets = get_list_of_facets(primary_key)
      partial_facets_data = facets.map(&method(:retrieve_facet_data))
      full_facets_data = update_total_new_records(partial_facets_data)
      create_metrics_records(full_facets_data)
    end

    private

    def get_list_of_facets(primary_key)
      facets_list = []
      facets_page = 1
      loop do
        s = RecordSearch.new({facets: primary_key, facets_per_page: 150, facets_page: facets_page})
        # HACK: We override SearchSerializable#facets_list in the api_app to 
        # replace :display_collection with :primary_collection, this transparently fixes it
        facets = remap_keys(facets_to_hash(s), {primary_collection: :display_collection})[primary_key.to_sym]

        # Gone past last page of facets
        break if facets.length == 0

        facets_list << facets.keys
        facets_page += 1
      end

      facets_list.flatten
    end

    def retrieve_facet_data(facet)
      s = RecordSearch.new({facets: secondary_keys.join(','), and: {primary_key.to_sym => facet}})
      facet_key_mappings = secondary_keys.reduce({}){|a, e| a.merge({e.to_sym => custom_key_to_field_name(e)})}
      facet_metadata = remap_keys(facets_to_hash(s), facet_key_mappings)

      {
        id: facet,
        day: Date.current,
        total_active_records: s.total,
        total_new_records: 0
      }.merge(facet_metadata)
    end

    def update_total_new_records(facets)
      facets = facets.dup
      records = Record.active.created_on_day(Date.current)
      counts_grouped_by_primary_key = records.group_by(&primary_key.to_sym).map{|k, v| [k, v.length]}

      counts_grouped_by_primary_key.each do |primary_key, count|
        facet_to_update = facets.find{|x| x[:id] == primary_key}
        
        next unless facet_to_update.present?

        facet_to_update[:total_new_records] = count
      end

      facets
    end

    def create_metrics_records(facets)
      active_records = Record.active
      total_records = active_records.count
      total_new_records = active_records.created_on_day(Date.current).count

      DailyItemMetric.create(
        day: Date.current,
        total_active_records: total_records,
        total_new_records: total_new_records
      )

      facets.each{|x| FacetedMetrics.create(x)}
    end
    
    def facets_to_hash(facets_response)
      facets = {}
      facets_response.facets.each do |facet|
        rows = {}
        facet.rows.each do |row|
          rows[row.value] = row.count
        end

        facets.merge!({facet.name => rows})
      end
      facets
    end

    def custom_key_to_field_name(key) 
      "#{key}_counts".to_sym
    end

    def remap_keys(target, mappings)
      Hash[target.map{|k, v| [mappings[k] || k, v]}]
    end
  end
end
