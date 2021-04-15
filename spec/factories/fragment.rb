module SupplejackApi
  FactoryBot.define do

    factory :fragment, class: SupplejackApi::ApiRecord::RecordFragment do
      source_id             { 'source_name' }
      priority              { 0 }
      title                 { 'A record' }
      creator               { ['John Kennedy'] }
    end
  end
end
