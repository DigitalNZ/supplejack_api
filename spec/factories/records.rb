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
        tag ['foo', 'bar']
      end

      internal_identifier 'nlnz:1234'
      record_id              54_321
      status                 'active'
      source_url             'http://google.com/landing.html'
      record_type            0

      factory :record_with_fragment do
        fragments do
          [FactoryGirl.build(:record_fragment,
                             display_collection: display_collection,
                             copyright: copyright,
                             category: category,
                             tag: tag)]
        end
      end

      factory :record_with_no_large_thumb do
        fragments do
          [FactoryGirl.build(:record_fragment,
                             display_collection: display_collection,
                             copyright: copyright,
                             category: category,
                             tag: tag,
                             large_thumbnail_url: nil)]
        end
      end

    end

    factory :record_fragment, class: SupplejackApi::ApiRecord::RecordFragment do
      title           'title'
      content_partner  ['content partner']
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
      large_thumbnail_url    'http://my-website-that-hosts-images/image.png'
      thumbnail_url    'http://my-website-that-hosts-images/small-image.png'
      landing_url      'http://my-website'
      subject         []
    end
  end
end
