module SupplejackApi
  FactoryGirl.define do
    factory :source, class: SupplejackApi::Source do
      name        "Sample source"
      source_id   "1234"
    end
  end

end
