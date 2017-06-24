# frozen_string_literal: true

# This model is a temporary store to log every request to index, show action for a UserSet
# This data is used by interaction udpaters to create UsageMetric entries and deleted after
module SupplejackApi
  module InteractionModels
    class Set
      include Mongoid::Document
      include Mongoid::Timestamps

      # Potential values are :creation and :view
      field :interaction_type,   type: Symbol
      field :facet, type: String
    end
  end
end
