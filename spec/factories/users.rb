# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :user, class: SupplejackApi::User do
      sequence(:authentication_token)

      daily_requests        { 0 }
      max_requests          { 1000 }
      role                  { 'developer' }
      name                  { Faker::Name.name }
      username              { Faker::Name.first_name.downcase }
      email                 { Faker::Internet.email }

      factory :admin_user do
        role { 'admin' }
      end

      factory :harvest_user do
        role { 'harvester' }
      end
    end
  end
end
