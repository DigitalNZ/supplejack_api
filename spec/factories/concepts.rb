# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :concept, class: SupplejackApi::Concept do
      sequence(:concept_id)
      concept_type  { 'edm:Agent' }
      name          { 'Colin McCahon' }
      dateOfBirth   { 1991 }
      dateOfDeath   { 1992 }
      note          { 'Concept is a Est mollitia neque magnam id. Doloremque et et consectetur et aut.' }
      latitude      { -38.1368478 }
      longitude     { 176.2497461 }
      title         { 'Title' }
      biographicalInformation { 'Bio' }
    end

    trait :place do
      concept_type  { 'edm:Place' }
    end
  end
end
