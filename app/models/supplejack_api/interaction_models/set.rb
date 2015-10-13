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
