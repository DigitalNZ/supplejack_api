# frozen_string_literal: true

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

    validates :date, uniqueness: true

    IMPLICIT_FIELDS = %w[_type _id created_at updated_at].freeze

    def self.generate_activity(time = Time.zone.now)
      site_activity_date = time.to_date
      user_activities = SupplejackApi::UserActivity.gt(created_at: time - 12.hours).lte(created_at: time)

      attributes = { user_sets: 0, search: 0, records: 0 }

      user_activities.each do |user_activity|
        %i[user_sets search records].each do |field|
          attributes[field] += user_activity.send(field)['total'] if user_activity.send(field)
        end
      end

      # The date stored is yesterday's date since the activity corresponds to the day before.
      attributes[:date] = site_activity_date

      site_activity = new(attributes)
      site_activity.source_clicks = SupplejackApi::SourceActivity.get_source_clicks || 0
      SupplejackApi::SourceActivity.reset
      site_activity.calculate_total
      site_activity.save!
      site_activity
    end

    def self.activities
      %w[date search user_sets records source_clicks total] - IMPLICIT_FIELDS
    end

    def calculate_total
      self.total = user_sets + records + search + source_clicks
    end
  end
end
