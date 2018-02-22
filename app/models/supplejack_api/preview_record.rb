# frozen_string_literal: true

module SupplejackApi
  class PreviewRecord
    # These records are used for previewing in squirrel, expire after 60 seconds

    include Support::Storable
    include Support::FragmentHelpers
    include Support::Harvestable

    store_in collection: 'preview_records'

    embeds_many :fragments, cascade_callbacks: true, class_name: 'SupplejackApi::ApiRecord::RecordFragment'
    embeds_one :merged_fragment, class_name: 'SupplejackApi::ApiRecord::RecordFragment'

    auto_increment :record_id, session: 'strong', collection: 'preview_sequences'

    build_model_fields

    def fragment_class
      SupplejackApi::ApiRecord::RecordFragment
    end
  end
end
