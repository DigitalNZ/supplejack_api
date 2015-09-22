# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UsageMetrics
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: 'usage_metrics'

    field :record_field_value, type: String
    field :searches,         	 type: Integer, default: 0
    field :gets,             	 type: Integer, default: 0
    field :user_set_views,   	 type: Integer, default: 0
    field :total,              type: Integer, default: 0
    field :day,                type: Date

    def self.created_on(date)
      where(:day.gte => date.at_beginning_of_day, :created_at.lte => date.at_end_of_day)
    end

    def self.created_between(start_date, end_date)
      binding.pry
      where(:day.gte => start_date.at_beginning_of_day, :day.lte => end_date.at_end_of_day)
    end

    # rubocop:disable Metrics/MethodLength
    # FIXME: make method smaller
    def self.build_metrics
      Rails.logger.level = 1 unless Rails.env.development?
      Rails.logger.info "UsageMetrics:[#{Time.zone.now}]: build"

      search_counts,   search_ids   = self.build_hash_for("search")
      get_counts,      get_ids      = self.build_hash_for("get")
      user_set_counts, user_set_ids = self.build_hash_for("user_set")

      Rails.logger.info "UsageMetrics:[#{Time.zone.now}]: Hashes built"

      unique_field_values = (search_counts.keys + get_counts.keys + user_set_counts.keys).uniq

      # Creating metrics for each primary collection
      unique_field_values.each do |field_value|
        usage_metric_entry = SupplejackApi::UsageMetrics.where(
          :created_at.gt => Date.today, 
          :record_field_value => field_value.to_s
        ).first

        # # set everything to default value of 0 if no value is present, makes following code simpler
        [search_counts, get_counts, user_set_counts].each do |x|
          x[field_value] = 0 unless x[field_value]
        end

        if usage_metric_entry.nil?
          self.create(
            record_field_value: field_value.to_s, 
            searches: search_counts[field_value], 
            gets: get_counts[field_value],
            user_set_views: user_set_counts[field_value],
            total: search_counts[field_value] + user_set_counts[field_value] + get_counts[field_value],
            day: Date.current
          )
        else
          searches       = usage_metric_entry.searches       + search_counts[field_value]
          gets           = usage_metric_entry.gets           + get_counts[field_value]
          user_set_views = usage_metric_entry.user_set_views + user_set_counts[field_value]

          total = searches + gets + user_set_views

          usage_metric_entry.update(
            searches: searches,
            gets: gets,
            user_set_views: user_set_views,
            total: total
          )
        end
      end    	

      # Deleting all the RequestLogs just counted
      Rails.logger.info "UsageMetrics:[#{Time.zone.now}]: Deleting RequestLogs"
      (search_ids + get_ids + user_set_ids).each do |id|
        SupplejackApi::RequestLog.find(id).delete
      end
      Rails.logger.info "UsageMetrics:[#{Time.zone.now}]: Complete"
    end
    # rubocop:enable Metrics/MethodLength

    def self.build_hash_for(request_type)
      request_logs = SupplejackApi::RequestLog.where(request_type: request_type)
      request_log_counts = {}

      request_logs.each do |request_log|
        if request_log.log_values
          request_log.log_values.compact.each do |field|
            key = field.to_sym
            unless request_log_counts.has_key? key
              request_log_counts[key] = 1
            else
              request_log_counts[key] += 1
            end
          end
        end	
      end

      [request_log_counts, request_logs.map(&:id)]
    end

  end
end
