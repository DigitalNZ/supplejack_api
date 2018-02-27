

module SupplejackApi
  FactoryBot.define do
    factory :set_interaction, class: SupplejackApi::InteractionModels::Set do
      facet 'test'
      interaction_type :creation
    end
  end
end
