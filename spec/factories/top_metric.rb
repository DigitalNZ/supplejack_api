module SupplejackApi
  FactoryBot.define do
    factory :top_metric, class: SupplejackApi::TopMetric do
      metric { 'appeared_in_searches' }
    end
  end
end
