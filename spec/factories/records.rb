# frozen_string_literal: true

module SupplejackApi
  FactoryBot.define do
    factory :record, class: SupplejackApi::Record do
      transient do
        display_collection { 'test' }
        copyright          { ['0'] }
        category           { ['0'] }
        tag                { %w[foo bar] }
      end

      internal_identifier { 'nlnz:1234' }
      record_id { 54_123 }
      status                 { 'active' }
      source_url             { 'http://google.com/landing.html' }
      record_type            { 0 }

      factory :record_with_fragment do
        fragments do
          [FactoryBot.build(:record_fragment,
                            display_collection: display_collection,
                            copyright: copyright,
                            category: category,
                            tag: tag)]
        end

        # rubocop:disable Style/SymbolProc
        after(:build) do |record_with_fragment|
          record_with_fragment.save!
        end
        # rubocop:enable Style/SymbolProc

        trait :ready_for_indexing do
          index_updated { false }
        end

        trait :deleted do
          status { 'deleted' }
        end
      end

      factory :record_with_no_large_thumb do
        fragments do
          [FactoryBot.build(:record_fragment,
                            display_collection: display_collection,
                            copyright: copyright,
                            category: category,
                            tag: tag,
                            large_thumbnail_url: nil)]
        end
      end
    end

    factory :record_fragment, class: SupplejackApi::ApiRecord::RecordFragment do
      title               { 'title' }
      content_partner     { ['content partner'] }
      source_id           { 'source_name' }
      priority            { 0 }
      name                { 'John Doe' }
      address             { 'Wellington' }
      email               { ['johndoe@example.com'] }
      children            { ['Sally Doe', 'James Doe'] }
      contact             { nil }
      age                 { 30 }
      birth_date          { Time.now.utc }
      nz_citizen          { true }
      display_collection  { 'test' }
      large_thumbnail_url { 'http://my-website-that-hosts-images/image.png' }
      thumbnail_url       { 'http://my-website-that-hosts-images/small-image.png' }
      landing_url         { 'http://my-website' }
      subject             { [] }
      job_id              { '54' }
    end
  end
end
