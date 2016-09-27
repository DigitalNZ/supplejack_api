FactoryGirl.define do
  factory :story_block, class: Hash do
    position 1
    type 'text'
    sub_type 'heading'

    initialize_with { attributes }

    factory :heading_block do
      type 'text'
      sub_type 'heading'
      content {{value: 'foo'}}
      meta {{size: '1'}}
    end

    factory :rich_text_block do
      type 'text'
      sub_type 'rich_text'
      content {{value: 'foo'}}
    end
  end
end
