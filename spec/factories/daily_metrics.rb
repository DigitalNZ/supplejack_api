require 'faker'

module SupplejackApi
  FactoryGirl.define do
    factory :daily_metrics, class: SupplejackApi::DailyMetrics do
      total_public_sets 10
      date              {Date.current}
    end
  end
end
