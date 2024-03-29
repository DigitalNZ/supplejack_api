# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :partner, class: SupplejackApi::Partner do
      name { 'Statistics New Zealand' }
    end
  end
end
