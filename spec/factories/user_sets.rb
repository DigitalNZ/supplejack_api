# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :user_set, class: SupplejackApi::UserSet do
      name            "Dogs and cats"
      description     "Ugly dogs and cats"
      user
      factory :user_set_with_set_item do
        after(:create) do |user_set|
          user_set.set_items.build(attributes_for(:set_item))
          user_set.save
        end
      end
    end

    factory :set_item, class: SupplejackApi::SetItem do
      record_id 12345
      position  1
    end
  end
end
