module SupplejackApi
  FactoryGirl.define do
    factory :user, class: SupplejackApi::User do
      authentication_token  '12345'
      daily_requests        0
      max_requests          1000
      role                  'developer'
    end
  end
  
  FactoryGirl.define do
    factory :user_activity, class: SupplejackApi::UserActivity do
      total 10
    end
  end

end
