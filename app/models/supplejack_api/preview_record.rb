# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class PreviewRecord
    # These records are used for previewing in squirrel, expire after 60 seconds

    include Support::Storable
    include Support::FragmentHelpers
    include Support::Harvestable

    store_in collection: 'preview_records'

    embeds_many :fragments, cascade_callbacks: true, class_name: 'SupplejackApi::ApiRecord::RecordFragment'
    embeds_one :merged_fragment, cascade_callbacks: true, class_name: 'SupplejackApi::ApiRecord::RecordFragment'

    auto_increment :record_id, session: 'strong', collection: 'preview_sequences'

    build_model_fields

    def fragment_class
      SupplejackApi::ApiRecord::RecordFragment
    end
  end
end
