require 'faker'

module SupplejackApi
  FactoryGirl.define do
    factory :daily_item_metric, class: SupplejackApi::DailyItemMetric do
      transient do
        number_of_display_collections 2
        display_collection_names ['dc1', 'dc2']
      end

      total_active_records 10
      total_new_records 1
      day {Date.current}

      after :create do |metric, evaluator|
        evaluator.number_of_display_collections.times do |i| 
          override = {name: evaluator.display_collection_names[i]}
          metric.display_collection_metrics.build(FactoryGirl.attributes_for(:display_collection_metric, override))
        end
        metric.save
      end
    end
  end
end
