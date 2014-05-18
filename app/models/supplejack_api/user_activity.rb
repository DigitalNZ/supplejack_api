# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UserActivity
    include Mongoid::Document
    include Mongoid::Timestamps
  
    store_in collection: 'user_activities'
    
    belongs_to :user, class_name: 'SupplejackApi::User'
  
    field :user_sets,       type: Hash
    field :search,          type: Hash
    field :records,         type: Hash
    field :custom_searches, type: Hash
    field :total,           type: Integer
  
    index created_at: 1
  
    def self.build_from_user(daily_activity)
      user_activity = new
      daily_activity ||= {}
  
      ['user_sets', 'search', 'records', 'custom_searches'].each do |group|
        group_activity = daily_activity[group]
  
        if group_activity
          user_activity[group] = group_activity
          user_activity.calculate_total_for(group)
        end
      end
  
      user_activity.calculate_total
      user_activity
    end
  
    def calculate_total_for(field)
      total = 0
  
      if activities = self[field]
        activities.each {|action, count| total += count.to_i}
      else
        activities = {}
      end
  
      activities['total'] = total
      self[field] = activities
    end
  
    def calculate_total
      count = 0
      ['user_sets', 'search', 'records', 'custom_searches'].each do |group|
        values = self.send(group)
        count += values['total'].to_i if values && values.is_a?(Hash)
      end
      self.total = count
    end
  end
end
