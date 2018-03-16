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
          create :set_item, user_set: user_set
        end
      end
    end

    factory :set_item, class: SupplejackApi::SetItem do
      before(:create) do |set_item|
        record = create(:record_with_fragment)
        set_item.record_id = record.record_id
      end
      sequence(:position)
    end
  end
end
