# frozen_string_literal: true

module SupplejackApi
  class BaseParams
    include SupplejackApi::Concerns::ModelSchemaParams
    include SupplejackApi::Concerns::PaginationParams
    include SupplejackApi::Concerns::FacetsPaginationParams
    include SupplejackApi::Concerns::OrderingParams
    include SupplejackApi::Concerns::FieldsParams
    include SupplejackApi::Concerns::FacetsParams
    include SupplejackApi::Concerns::HelpersParams
    include SupplejackApi::Concerns::GeoParams
    include SupplejackApi::Concerns::WithoutParams
    include SupplejackApi::Concerns::TextParams

    attr_reader :errors

    def initialize(**kwargs)
      @params = kwargs.reverse_merge!(defaults).symbolize_keys
      @errors = []
    end
  end
end
