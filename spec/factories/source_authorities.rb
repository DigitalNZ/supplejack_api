

module SupplejackApi
  FactoryBot.define do
    factory :source_authority, class: SupplejackApi::SourceAuthority do
      association :concept, factory: :concept

      add_attribute :_mn_given_name do
        'name'
      end

      internal_identifier   { 'tepapa:1502' }
      source_id             { 'tepapa' }
      source_name           { 'Te Papa - Museum of New Zealand' }
      url                   { 'http://collections.tepapa.govt.nz/Person/1502' }
    end
  end
end
