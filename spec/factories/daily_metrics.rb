require 'faker'

module SupplejackApi
  FactoryBot.define do
    factory :daily_metrics, class: SupplejackApi::DailyMetrics do
      total_public_sets 10
      date              {Time.now.utc.to_date}
    end
  end
end
