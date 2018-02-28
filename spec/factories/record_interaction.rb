module SupplejackApi
  module InteractionModels
    FactoryBot.define do
      factory :record_interaction, class: SupplejackApi::InteractionModels::Record do
        request_type 'search'
        log_values   ['Voyager 1', 'Sputnik', 'Explorer']
      end
    end
  end
end
