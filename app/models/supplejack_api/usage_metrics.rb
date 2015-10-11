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
      where(:day.gte => start_date.at_beginning_of_day, :day.lte => end_date.at_end_of_day)
    end
  end
end
