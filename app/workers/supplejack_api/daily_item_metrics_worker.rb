# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class DailyItemMetricsWorker

    @queue = :daily_item_metrics

    def initialize
      # configuration for metrics logging
      # the primary_key is what the records get grouped on
      # the secondary_keys are the fields counted, they must be multivalue fields
      # if the secondary_keys are changed the DisplayCollectionMetric model must be updated
      # so that the field names match the new secondary_key names
      @primary_key = :display_collection
      @secondary_keys = [
        :category,
        :copyright
      ]
    end

    def self.perform
      self.new.call(Date.yesterday)
    end

    def call(date)
      records = Record.active.created_before(date + 1.day)
      collection_metrics = perform_map_reduce(records, date)

      BuildMetricsData.new(@primary_key, @secondary_keys)
                      .call(collection_metrics, 
                            records,
                            date)
    end

    private
 
    # rubocop:disable Metrics/MethodLength
    def perform_map_reduce(records, date)
      # this is inserted into the map/reduce JS so they can access the configuration variables
      config_js = %(
        var primaryKey = '#{@primary_key}';
        var secondaryKeys = [#{@secondary_keys.reduce(''){|a, e| a + "'#{e}',"}.chomp(',')}];
      )
      map = %{
        function() {
          #{config_js}
          var fragment = this.fragments[0];
          if(fragment) {
            //The month argument is 0 indexed in a Javascript Date object
            var checkDate = new Date(#{date.year}, #{date.month - 1}, #{date.day})
            var name = fragment[primaryKey] || 'Unknown';

            var metrics = secondaryKeys.map(function(key) {
              var map = {};
              var items = fragment[key];

              if(items) {
                for(var i = 0;i < items.length;i++) {
                  var itemKey = items[i];
                  if(map[itemKey] == undefined)
                    map[itemKey] = 0
                  map[itemKey] += 1
                }
              }

              return map;
            });

            var newCount = checkDate <= this.created_at ? 1 : 0;
            var result = {name: name, newCount: newCount, count: 1};

            for(var i = 0;i < metrics.length;i++) {
              if(Object.keys(metrics[i]).length !== 0)
                result[secondaryKeys[i]] = metrics[i];
            }

            if(name) {
              emit(name, result);
            }
          }
        }
      }
      reduce = %{
        function(key, values) {
          #{config_js}
          var result = {name: key, count: 0, newCount: 0};
          values.forEach(function(v) {
            result.count += v.count;
            result.newCount += v.newCount;

            secondaryKeys.forEach(function(key) {
              if(result[key] == undefined)
                result[key] = {}

              if(v[key] == undefined) return;

              var keys = Object.keys(v[key]);
              keys.forEach(function(oKey) {
                if(result[key][oKey] == undefined)
                  result[key][oKey] = 0
                result[key][oKey] += v[key][oKey]
              });
            });
          });

          return result;
        }
      }

      records.map_reduce(map, reduce).out(inline: true).to_a
    end
    # rubocop:enable Metrics/MethodLength

  end
  
  class BuildMetricsData
    
    def initialize(primary_key, secondary_keys)
      @primary_key = primary_key
      @secondary_keys = secondary_keys
    end

    def call(faceted_metrics, records_to_check, date)
      processed_faceted_metrics = faceted_metrics.map(&method(:process_faceted_metrics))

      build_full_metrics_data(processed_faceted_metrics, records_to_check, date)
    end

    private

    def process_faceted_metrics(faceted_metric)
      # unwrap metric data
      faceted_metric = faceted_metric[:value]

      hardcoded = {
        name:                 faceted_metric[:name],
        total_active_records: faceted_metric[:count],
        total_new_records:    faceted_metric[:newCount]
      }

      custom = @secondary_keys.select{|key| faceted_metric[key] != {}}
                              .reduce({}){|a, e| a.merge({custom_key_to_field_key(e) => faceted_metric[e]})}

      hardcoded.merge(custom)
    end

    def build_full_metrics_data(processed_faceted_metrics, records_to_check, date)
      total_active_records = records_to_check.count
      total_new_records = Record.active.created_on_day(date).count

      DailyItemMetric.create(
        day: date,
        total_active_records: total_active_records, 
        total_new_records: total_new_records
      )

      processed_faceted_metrics.each do |fm|
        FacetedMetrics.create(fm.merge({day: date}))
      end
    end

    def custom_key_to_field_key(key) 
      "#{key}_counts".to_sym
    end
  end
end
