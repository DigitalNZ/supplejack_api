require 'faker'

module SupplejackApi
  FactoryGirl.define do
    factory :daily_item_metric, class: SupplejackApi::DailyItemMetric do
      transient do
        number_of_display_collections 2
      end

      total_active_records 10
      # total_new_records 1
      day {Date.current}

      after :create do |metric, evaluator|
        evaluator.number_of_display_collections.times do 
          metric.display_collection_metrics.build(FactoryGirl.attributes_for(:display_collection_metric))
        end
        metric.save
      end
    end
  end
end
