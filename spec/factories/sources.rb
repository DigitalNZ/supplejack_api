

module SupplejackApi
  FactoryBot.define do
    factory :source, class: SupplejackApi::Source do
      association :partner, factory: :partner
      name        'Sample source'
      source_id   '1234'
    end
  end

end
