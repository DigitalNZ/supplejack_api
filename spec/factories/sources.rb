

module SupplejackApi
  FactoryBot.define do
    factory :source, class: SupplejackApi::Source do
      association :partner, factory: :partner
      source_id   '1234'
    end
  end

end
