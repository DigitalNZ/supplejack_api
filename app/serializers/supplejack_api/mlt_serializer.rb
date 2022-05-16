# frozen_string_literal: true

module SupplejackApi
  class MltSerializer < ActiveModel::Serializer
    include SupplejackApi::Concerns::SearchSerializer
  end
end
