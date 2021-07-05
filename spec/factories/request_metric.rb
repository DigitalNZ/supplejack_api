# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :request_metric, class: SupplejackApi::RequestMetric do
      metric { 'appeared_in_searches' }
      records do
        [{ record_id: 1001, display_collection: 'TAPHUI' },
         { record_id: 289, display_collection: 'Papers Past' },
         { record_id: 289, display_collection: 'Papers Past' },
         { record_id: 30, display_collection: 'TAPHUI' },
         { record_id: 411, display_collection: 'National Library of New Zealand' }]
      end
    end
  end
end
