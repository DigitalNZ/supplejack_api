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
      worker = self.new
      last_metrics = DailyItemMetric.last

      if last_metrics.present? 
        days_since_last_run = Date.current.mjd - last_metrics.day.mjd
        if days_since_last_run > 1
          # start from 2 so that we don't double up todays metrics
          (2...days_since_last_run).each do |n|
            worker.call(Date.current - n.days, DailyItemMetric.last)
          end
        end
      end

      # metrics are calculated after midnight so they are actually for yesterday
      worker.call(Date.current - 1.day, DailyItemMetric.last)
    end

    def call(date, previous_metrics=nil)
      records = Record.active.created_before(date + 1.day)
      records_to_check = previous_metrics.present? ? records.created_on_day(date) : records

      collection_metrics = perform_map_reduce(records_to_check, date)

      processed_collection_metrics = collection_metrics.map(&method(:process_collection_metrics))

      build_full_metrics_data(previous_metrics, processed_collection_metrics, records_to_check, date)
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

    def process_collection_metrics(pcm)
      # unwrap pcm data
      pcm = pcm[:value]

      hardcoded = {
        name:                 pcm[:name],
        total_active_records: pcm[:count],
        total_new_records:    pcm[:newCount]
      }

      custom = @secondary_keys.select{|key| pcm[key] != {}}
                              .reduce({}){|a, e| a.merge({custom_key_to_field_key(e) => pcm[e]})}

      hardcoded.merge(custom)
    end

    def build_full_metrics_data(previous_metrics, processed_display_collection_metrics, records_to_check, date)
      previous_dcms = previous_metrics.try(:display_collection_metrics) || []
      merged_display_collection_metrics = merge_display_collection_metrics(
        processed_display_collection_metrics, 
        previous_dcms
      )
      missing_metrics = previous_dcms.select do |m| 
        !merged_display_collection_metrics.any?{|mtm| mtm[:name] == m[:name]}
      end 

      total_active_records = records_to_check.count
      total_active_records += previous_metrics.try(:total_active_records) || 0

      daily_item_metric = DailyItemMetric.create(
        day: date,
        total_active_records: total_active_records, 
        display_collection_metrics_attributes: merged_display_collection_metrics
      )
      daily_item_metric.display_collection_metrics << missing_metrics
      daily_item_metric.save!

      daily_item_metric
    end

    def merge_display_collection_metrics(metrics_to_merge, existing_metrics)
      metrics_to_merge.each do |pcm|
        existing_pcm = existing_metrics.find{|x| x[:name] == pcm[:name]} || {}
        pcm[:total_active_records] += existing_pcm.try(:total_active_records) || 0

        pcm_group_updater = lambda do |accessor_symbol|
          lambda do |category_metric|
            name, count = category_metric
            existing_cm = (existing_pcm[accessor_symbol] || {}).select{|x| x == name} || {}

            [name, count + (existing_cm[name] || 0)]
          end
        end

        @secondary_keys.each do |k|
          key = custom_key_to_field_key(k)
          next unless pcm[key]

          pcm[key] = Hash[pcm[key].map(&pcm_group_updater.call(key))]
        end
      end
    end

    def custom_key_to_field_key(key) 
      "#{key}_counts".to_sym
    end
  end
end
