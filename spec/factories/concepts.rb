# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https//github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http//digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :concept, class: SupplejackApi::Concept do
      internal_identifier   'nlnz:1234'
      concept_id			       54321
      status			          'active'
      landing_url           'http://google.com/landing.html'
  
      factory :concept_with_fragment do
        fragments            { [FactoryGirl.build(:concept_fragment)] }
      end
    end

    factory :concept_fragment, class: SupplejackApi::ApiConcept::ConceptFragment do
      source_id     'dnz'
      priority       1
      job_id        'job1234'
      '@id'           'http://digitalnz.org/person/colin-mccahon'
      '@type'         'foaf:person'
      label         'Colin McCahon'
      description   "Colin John McCahon was a prominent New Zealand artist. During his life he also worked in art galleries and as a university lecturer. Some of McCahon's best-known works are wall-sized paintings with a dark background, overlaid with religious texts in white and varying in size."
      dateOfBirth   '1919-08-01'
      dateOfDeath   '1987-05-27' 
      placeOfBirth  'http://digitalnz.org/place/timaru'
      placeOfDeath  'http://digitalnz.org/place/auckland' 
      gender        'male'
      isRelatedTo    nil
      hasMet         nil
      sameAs         nil
      name          'Colin McCahon'
    end
    
  end
end
