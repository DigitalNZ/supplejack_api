# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :activity, class: SiteActivity do
      created_at 1.day.ago.utc
      updated_at Date.today
      date       { Faker::Date.birthday(18, 65) }
      user_sets 1264
      search    696979
      records   74680
      total     784091
      source_clicks 11168
    end
  end
end
