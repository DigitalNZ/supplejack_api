# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https//github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http//digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :concept, class: SupplejackApi::Concept do
      concept_id    1
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
