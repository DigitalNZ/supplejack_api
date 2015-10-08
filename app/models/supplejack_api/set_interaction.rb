module SupplejackApi
  class SetInteraction
    include Mongoid::Document
    include Mongoid::Timestamps

    # Potential values are :creation and :view
    field :interaction_type,   type: Symbol
    field :display_collection, type: String
    field :source_url,         type: String
  end
end
