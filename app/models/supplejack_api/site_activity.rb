# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class SiteActivity
    include Mongoid::Document
    include Mongoid::Timestamps
    include Sortable::Query

    store_in collection: 'site_activities'

    field :date,      type: Date
    field :user_sets, type: Integer
    field :search,    type: Integer
    field :records,   type: Integer
    field :source_clicks, type: Integer
    field :total,     type: Integer

    validates_uniqueness_of :date

    IMPLICIT_FIELDS = ['_type','_id','created_at','updated_at']

    def self.generate_activity(time=Time.now)
      site_activity_date = time.to_date
      user_activities = SupplejackApi::UserActivity.gt(created_at: time-12.hours).lte(created_at: time)

      attributes = {user_sets: 0, search: 0, records: 0}

      user_activities.each do |user_activity|
        [:user_sets, :search, :records].each do |field|
          attributes[field] += user_activity.send(field)['total'] if user_activity.send(field)
        end
      end

      # The date stored is yesterday's date since the activity corresponds to the day before.
      attributes[:date] = site_activity_date

      site_activity = new(attributes)
      site_activity.source_clicks = SupplejackApi::SourceActivity.get_source_clicks || 0
      SupplejackApi::SourceActivity.reset
      site_activity.calculate_total
      site_activity.save
      site_activity
    end

    def self.activities 
      ['date', 'search', 'user_sets', 'records', 'source_clicks', 'total'] - IMPLICIT_FIELDS
    end

    def calculate_total
      self.total = self.user_sets + self.records + self.search + self.source_clicks
    end
  end

end