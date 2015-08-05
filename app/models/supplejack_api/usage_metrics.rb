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
    
    field :record_field_value,      type: String
    field :searches,         		type: Integer, default: 0
    field :gets,             	    type: Integer, default: 0
    field :user_set_views,   	    type: Integer, default: 0
    field :total,                   type: Integer, default: 0

    def self.build_metrics
        search_counts, search_ids = self.build_hash_for("search")
        get_counts, get_ids = self.build_hash_for("get")
        user_set_counts, user_set_ids = self.build_hash_for("user_set")

        unique_field_values = (search_counts.keys + get_counts.keys + user_set_counts.keys).uniq

        # Creating metrics for each primary collection
        unique_field_values.each do |field_value|
            self.create(record_field_value: field_value.to_s, 
            searches: (search_counts[field_value] || 0), 
            gets: (get_counts[field_value] || 0),
            user_set_views: (user_set_counts[field_value] || 0),
            total: (search_counts[field_value] || 0) + (user_set_counts[field_value] || 0) + (get_counts[field_value] || 0))
        end    	

        # Deleting all the RequestLogs just counted
        (search_ids + get_ids + user_set_ids).each do |id|
            SupplejackApi::RequestLog.find(id).delete
        end
    end

    def self.build_hash_for(request_type)
    	# request_logs = SupplejackApi::RequestLog.gt(created_at: Time.now.to_date-25.hours).where(request_type: request_type)
    	request_logs = SupplejackApi::RequestLog.where(request_type: request_type)
    	request_log_counts = {}

    	request_logs.each do |request_log|
            if request_log.log_values
        		request_log.log_values.each do |field|
                    if field
            			if request_log_counts.has_key? field.to_sym
            				request_log_counts[field.to_sym] += 1
            			else
            				request_log_counts[field.to_sym] = 1
            			end
                    end	
        		end
            end    
    	end

      [request_log_counts, request_logs.map(&:id)]
    end

  end
end