# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryBot.define do
    factory :user_set, class: SupplejackApi::UserSet do
      association :record, factory: :record
      name            'Dogs and cats'
      description     'Ugly dogs and cats'
      user

      factory :user_set_with_set_item do
        after(:create) do |user_set|
          # This is needed to reset the memoized instance variable
          # @records that has been set in user_set
          # Without it you will not have set_items
          user_set.instance_variable_set(:@records, nil)
          record = FactoryBot.create(:record, record_id: 543_210)
           FactoryBot.create(:set_item, record_id: record.record_id, user_set: user_set)
           user_set.update_record
        end
      end
    end

    factory :set_item, class: SupplejackApi::SetItem do
      sequence(:position)
    end
  end
end
