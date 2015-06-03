# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :source_authority, class: SupplejackApi::SourceAuthority do
      internal_identifier   'tepapa:1502'
      concept_id             1
      concept_score          50
      source_id              'tepapa'
      source_name            'Te Papa - Museum of New Zealand'
      url                    'http://collections.tepapa.govt.nz/Person/1502'
    end
  end
end
