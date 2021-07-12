# frozen_string_literal: true

FactoryBot.define do
  factory :story, class: SupplejackApi::UserSet do
    association :record, factory: :record_with_fragment

    transient do
      number_of_story_items { 2 }
    end

    user
    name            { 'Story name' }
    description     { 'Story description' }
    featured        { false }
    approved        { false }
    tags            { %w[story tags] }
    copyright       { 0 }
    cover_thumbnail { 'https://thumbnail_url' }

    after(:create) do |story, evaluator|
      next unless story.set_items.empty?

      evaluator.number_of_story_items.times do
        story.set_items.build(attributes_for(:story_item))
      end

      story.save!
    end

    factory :story_with_dnz_story_items do
      after(:create) do |story, evaluator|
        evaluator.number_of_story_items.times do
          story.set_items.build(attributes_for(:embed_dnz_item))
        end
        story.save!
      end
    end
  end

  factory :story_json, class: Hash do
    transient do
      number_of_blocks { 2 }
    end
    sequence(:id)   { map(&:to_s) }
    sequence(:name) { |n| "Story #{n}" }
    privacy         { 'hidden' }
    featured        { false }
    approved        { false }
    description     { 'Story description' }
    tags            { %w[story tags] }
    number_of_items { number_of_blocks }
    contents        { [] }
    copyright       { 0 }

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
