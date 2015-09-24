# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :record, class: SupplejackApi::Record do
      transient do
        display_collection 'test'
        copyright ['0']
        category ['0']
      end

      internal_identifier   'nlnz:1234'
      record_id              54321
      status                 'active'
      source_url             'http://google.com/landing.html'
      record_type            0
  
      factory :record_with_fragment do 
        fragments            { [FactoryGirl.build(:record_fragment, 
                                                  display_collection: display_collection, 
                                                  copyright: copyright, 
                                                  category: category
                                                 )] }
      end    
    end
  
    factory :record_fragment, class: SupplejackApi::ApiRecord::RecordFragment do
      source_id       'source_name'
      priority        0
      name            'John Doe'
      address         'Wellington'
      email           ['johndoe@example.com']
      children        ['Sally Doe', 'James Doe']
      contact         nil
      age             30
      birth_date      DateTime.now
      nz_citizen      true
      display_collection 'test'
    end  
  end

end
