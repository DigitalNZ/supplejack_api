FactoryBot.define do
  factory :story_item, class: SupplejackApi::SetItem do
    user_set
    sequence(:position)
    type 'text'
    sub_type 'heading'
    content {{value: 'foo', image_url: ('a'..'z').to_a.shuffle.join, display_collection: 'TAPHUI', category: ['Audio']}}
    meta {{size: 1}}
    record_id { SecureRandom.random_number(1000000) }

    trait :script_value do
      content { { value: '<script>alert("test");<script>' } }
    end

    trait :inline_style_value do
      content { { value: '<p style="display: none;">my paragraph</p>' } }
    end

    factory :heading_item do
      type 'text'
      sub_type 'heading'
      content {{value: 'foo'}}
      meta {{size: 1}}
    end

    factory :rich_text_item do
      type 'text'
      sub_type 'rich-text'
      content {{value: 'foo'}}
    end

    factory :embed_dnz_item do
      transient do
        title 'A title'
        display_collection 'Display collection'
        category 'Category'
        image_url 'http://foo.bar'
        tags ['tags', 'yo']

        alignment 'left'
        caption 'a caption'
      end

      type 'embed'
      sub_type 'record'

      record do
        create(
          :record,
          title: title,
          display_collection: display_collection,
          category: category,
          tags: tags
        )
      end

      content {{
        id: record.record_id,
        title: title,
        display_collection: display_collection,
        category: category,
        image_url: image_url,
        tags: tags
      }}

      meta {{
        alignment: alignment,
        caption: caption
      }}
    end

  end
end
