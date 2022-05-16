# frozen_string_literal: true

module SupplejackApi
  class SearchParams < BaseParams
    attr_accessor(
      :schema_class,
      :model_class,
      :geo_bbox,
      :and_condition,
      :or_condition,
      :without,
      :record_type,
      :exclude_filters_from_facets,
      :suggest,
      :text,
      :solr_query,
      :debug
    )

    class_attribute :max_values

    self.max_values = {
      page: 100_000,
      per_page: 100,
      facets_per_page: 350,
      facets_page: 5000
    }

    def initialize(**kwargs)
      super(**kwargs)

      init_model_schema_params(**@params)
      init_pagination(**@params)
      init_facets_pagination(**@params)
      init_ordering(**@params)
      init_fields(**@params)
      init_facets(**@params)
      init_geo_bbox(**@params)
      init_without(**@params)
      init_text(**@params)

      @suggest = @params[:suggest] == 'true'
      @and_condition = @params[:and]
      @or_condition = @params[:or]
      @record_type = @params[:record_type]

      @solr_query = @params[:solr_query]
      @debug = @params[:debug] == 'true'
    end

    private

    def defaults
      {
        and: {},
        or: {},
        record_type: 0,
        suggest: 'false',
        solr_query: ''
      }
    end
  end
end
