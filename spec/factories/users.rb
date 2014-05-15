# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
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
    end

    factory :user_activity, class: SupplejackApi::UserActivity do
      total 10
    end
  end
end
