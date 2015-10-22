require 'faker'

module SupplejackApi
  FactoryGirl.define do
    factory :daily_metrics, class: SupplejackApi::DailyMetrics do
      total_active_records 10
      total_new_records    1
      date                 {Date.current}
    end
  end
end
