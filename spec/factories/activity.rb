# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :activity, class: SiteActivity do
      created_at { 1.day.ago.utc }
      updated_at { Time.now.utc.to_date }
      date       { Faker::Date.birthday(min_age: 18, max_age: 65) }
      user_sets  { 1264 }
      search     { 696979 }
      records    { 74680 }
      total      { 784091 }
      source_clicks { 11168 }
    end
  end
end
