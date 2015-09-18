require 'faker'

module SupplejackApi
  FactoryGirl.define do
    factory :daily_item_metric, class: SupplejackApi::DailyItemMetric do
      total_active_records 10
      total_new_records 1
      day {Date.current}
    end
  end
end
