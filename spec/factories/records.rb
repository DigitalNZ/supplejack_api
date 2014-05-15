# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :record, class: SupplejackApi::Record do
      internal_identifier   'nlnz:1234'
      record_id			         54321
      status			           'active'
      landing_url            'http://google.com/landing.html'
  
      factory :record_with_fragment do
        fragments            { [FactoryGirl.build(:fragment)] }
      end
    end
  
    factory :fragment, class: SupplejackApi::Fragment do
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
