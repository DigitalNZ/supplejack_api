
module SupplejackApi
  FactoryBot.define do
    factory :top_collection_metric, class: SupplejackApi::TopCollectionMetric do
      metric { 'appeared_in_searches' }
    end
  end
end
