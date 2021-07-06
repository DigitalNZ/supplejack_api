# frozen_string_literal: true

FactoryBot.define do
  factory :story_block, class: Hash do
    position { 1 }
    type     { 'text' }
    sub_type { 'heading' }

    initialize_with { attributes }

    factory :heading_block do
      type     { 'text' }
      sub_type { 'heading' }
      content  { { value: 'foo' } }
      meta     { { size: 1 } }
    end

    factory :rich_text_block do
      type     { 'text' }
      sub_type { 'rich-text' }
      content  { { value: 'foo' } }
    end

    factory :embed_dnz_block do
      transient do
        id                 { 123 }
        title              { 'A title' }
        display_collection { 'Display collection' }
        category           { 'Category' }
        image_url          { 'http://foo.bar' }
        tags               { %w[tags yo] }
        alignment          { 'left' }
        caption            { 'a caption' }
      end

      type     { 'embed' }
      sub_type { 'record' }
      content do
        { id: id,
          record: {
            title: title,
            display_collection: display_collection,
            category: category,
            image_url: image_url,
            tags: tags
          } }
      end

      meta { { alignment: alignment, caption: caption } }
    end
  end
end
