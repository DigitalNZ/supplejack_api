# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :user_activity, class: SupplejackApi::UserActivity do
      total { 10 }
    end
  end
end
