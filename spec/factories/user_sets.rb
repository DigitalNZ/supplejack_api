module SupplejackApi
  FactoryBot.define do
    factory :user_set, class: SupplejackApi::UserSet do
      association :record, factory: :record_with_fragment
      association :user, factory: :user

      name             { Faker::Movie.title }
      description      { Faker::Movie.quote }
      copyright        { 0 }
      url              { Faker::Internet.url }
      priority         { 0 }
      count_updated_at { Date.today }
      subjects         { [Faker::Verb.base] }
      approved         { false }
      featured         { false }
      featured_at      { Date.today }
      cover_thumbnail  { Faker::Internet.url }
      username         { nil }


      factory :user_set_with_set_item do
        after(:create) do |user_set|
          # This is needed to reset the memoized instance variable
          # @records that has been set in user_set
          # Without it you will not have set_items
          user_set.instance_variable_set(:@records, nil)
          create :set_item, type: 'embed', sub_type: 'record', meta: { alignment: 'left' }, user_set: user_set
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
