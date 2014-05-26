# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :concept, class: SupplejackApi::Concept do
      internal_identifier   'nlnz:1234'
      concept_id			         54321
      status			           'active'
      landing_url            'http://google.com/landing.html'
  
      factory :concept_with_fragment do
        fragments            { [FactoryGirl.build(:concept_fragment)] }
      end
    end

    factory :concept_fragment, class: SupplejackApi::ApiConcept::ConceptFragment do
      source_id       'source_name'
      priority        0
      name            'John Doe'
      address         'Wellington'
      email           ['johndoe@example.com']
      children			  ['Sally Doe', 'James Doe']
      contact         nil
      age             30
      birth_date      DateTime.now
      nz_citizen	    true
    end
    
  end
end
