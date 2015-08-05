# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RequestLog
    include Mongoid::Document
    include Mongoid::Timestamps
  
    store_in collection: 'request_log'
    
    field :request_type, type: String
    field :log_values,    type: Array

    def self.create_search(object, field)
    	begin
	    	results = object.results.map(&field.to_sym).flatten
	    	self.create(request_type: "search", log_values: results) unless results.empty?
	    rescue
	    	Rails.logger.warn "[RequestLog][Warning] Field #{field} does not exist"
	    end
    end

    def self.create_find(object, field)
    	begin
    		result = object.send(field.to_sym)
    		result = [result] unless result.is_a? Array
    		self.create(request_type: "get", log_values: result) unless result.empty?
    	rescue
    		Rails.logger.warn "[RequestLog][Warning] Field #{field} does not exist"
    	end
    end

    def self.create_user_set(object, field)
    	begin
        results = [] 
        unless object.set_items.empty?
          object.set_items.each do |item|
            record = SupplejackApi::Record.custom_find(item.record_id)
            if record
            	result = record.send(field.to_sym)
              results << result if result
            end
          end
        end

    		self.create(request_type: "user_set", log_values: results.flatten) unless results.empty?
    	rescue
    		Rails.logger.warn "[RequestLog][Warning] Field #{field} does not exist"
    	end    	
    end
    
  end
end
