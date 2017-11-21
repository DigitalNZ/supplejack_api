# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryBot.define do
    factory :source_authority, class: SupplejackApi::SourceAuthority do
      association :concept, factory: :concept

      add_attribute :_mn_given_name do
        'name'
      end

      internal_identifier   'tepapa:1502'
      source_id              'tepapa'
      source_name            'Te Papa - Museum of New Zealand'
      url                    'http://collections.tepapa.govt.nz/Person/1502'
    end
  end
end
