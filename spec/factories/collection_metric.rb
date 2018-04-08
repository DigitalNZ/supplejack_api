
module SupplejackApi
  FactoryBot.define do
    factory :collection_metric, class: SupplejackApi::CollectionMetric do
      display_collection 'TAPHUI'
    end
  end
end
