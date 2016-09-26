FactoryGirl.define do
  factory :story, class: Hash do
    transient do
      number_of_blocks 2
    end

    sequence(:id) {|n| n.to_s }
    sequence(:name) {|n| "Story #{n}"}
    privacy 'hidden'
    featured false
    approved false
    description 'Story description'
    tags ['story', 'tags']
    number_of_items { number_of_blocks }
    contents []

    after(:build) do |story, evaluator|
      unless story[:contents].empty?
        story[:number_of_items] = story[:contents].length
        next
      end

      evaluator.number_of_blocks.times do
        story[:contents] << build(:heading_block)
      end
    end

    initialize_with { attributes }
  end
end
