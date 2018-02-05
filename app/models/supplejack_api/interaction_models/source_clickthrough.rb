# frozen_string_literal: true

module SupplejackApi
  module InteractionModels
    class SourceClickthrough
      include Mongoid::Document
      include Mongoid::Timestamps

      field :facet, type: String
    end
  end
end
