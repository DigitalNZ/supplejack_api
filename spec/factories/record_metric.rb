

module SupplejackApi
  FactoryBot.define do
    factory :record_metric, class: SupplejackApi::RecordMetric do
      sequence(:record_id)
    end
  end
end
