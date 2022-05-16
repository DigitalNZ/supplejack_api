# frozen_string_literal: true

module SupplejackApi
  class SearchSerializer < ActiveModel::Serializer
    include SupplejackApi::Concerns::SearchSerializer
    include SupplejackApi::Concerns::FacetsSerializer
  end
end
