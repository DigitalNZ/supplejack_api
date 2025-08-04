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
      :debug,
      :group_by,
      :group_order_by,
      :group_sort,
      :facet_range,
      :facet_range_start,
      :facet_range_end,
      :facet_range_interval
    )

    class_attribute :max_values

    self.max_values = {
      page: @user.nil? || @user&.role == 'anonymous' ? 100 : 50_000,
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
      init_group(**@params)
      init_facet_range(**@params)

      @suggest = @params[:suggest] == 'true'
      @and_condition = @params[:and]
      @or_condition = @params[:or]
      @record_type = @params[:record_type]

      @solr_query = @params[:solr_query]
      @debug = @params[:debug] == 'true'
      @user = User.find_by_auth_token(request.headers['Authentication-Token'] || params[:api_key])
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
