module SupplejackApi
  FactoryBot.define do
    factory :concept, class: SupplejackApi::Concept do
      sequence(:concept_id)
      concept_type  'edm:Agent'
      name          'Colin McCahon'
      biographicalInformation 'Bio'
      dateOfBirth   1991
      dateOfDeath   1992
      note          'Concept is a Est mollitia neque magnam id. Doloremque et et consectetur et aut. In voluptas sunt et ut aut.'
      latitude      -38.1368478
      longitude     176.2497461
      title         'Title'
    end

    trait :place do
      concept_type  'edm:Place'
    end
  end
end
