# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :activity, class: SiteActivity do
      created_at { 1.day.ago.utc }
      updated_at { Time.now.utc.to_date }
      date       { Faker::Date.birthday(18, 65) }
      user_sets  { 1264 }
      search     { 696_979 }
      records    { 74_680 }
      total      { 784_091 }
      source_clicks { 11_168 }
    end
  end
end
