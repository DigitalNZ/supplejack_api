# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :user, class: SupplejackApi::User do
      authentication_token  '12345'
      daily_requests        0
      max_requests          1000
      role                  'developer'

      factory :admin_user do
        role                'admin'
        email               'admin@example.com'
        password            'p@ssw0rd'
      end
    end

    factory :user_activity, class: SupplejackApi::UserActivity do
      total 10
    end
  end
end
