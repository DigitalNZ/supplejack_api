# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :preview_record, class: SupplejackApi.config.preview_record_class do
      record_type { 0 }
      internal_identifier { 'youtube:fngqeb8ane8' }
      status { 'active' }
      record_id { 54 }
    end
  end
end
