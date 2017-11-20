FactoryBot.define do
  factory :story_item, class: SupplejackApi::SetItem do
    user_set
    sequence(:position)
    sequence(:record_id, 10000)
    type 'text'
    sub_type 'heading'
    content {{value: 'foo', image_url: ('a'..'z').to_a.shuffle.join}}
    meta {{size: 1}}

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
        sequence(:id, 123)
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
      content {{
        id: id,
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

      record do
        build(
          :record,
          record_id: id,
          title: title,
          display_collection: display_collection,
          category: category,
          tags: tags
        )
      end

      after(:create) do |item|
        item.record.save!
      end
    end

  end
end
