# frozen_string_literal: true

module SupplejackApi
  class SearchParams
    include SupplejackApi::Concerns::ModelSchemaParams
    include SupplejackApi::Concerns::PaginationParams
    include SupplejackApi::Concerns::FacetsPaginationParams
    include SupplejackApi::Concerns::OrderingParams
    include SupplejackApi::Concerns::FieldsParams
    include SupplejackApi::Concerns::FacetsParams
    include SupplejackApi::Concerns::HelpersParams

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
      kwargs = kwargs.reverse_merge!(defaults).symbolize_keys

      init_model_schema_params(**kwargs)
      init_pagination(**kwargs)
      init_facets_pagination(**kwargs)
      init_ordering(**kwargs)
      init_fields(**kwargs)
      init_facets(**kwargs)

      @suggest = kwargs[:suggest] == 'true'
      @geo_bbox = geo_param(kwargs[:geo_bbox])
      @text = text_param(kwargs[:text])
      @and_condition = kwargs[:and]
      @or_condition = kwargs[:or]
      @without = without_param(kwargs[:without])
      @record_type = kwargs[:record_type]

      @solr_query = kwargs[:solr_query]
      @debug = kwargs[:debug] == 'true'
    end

    private

    def without_param(without_param)
      without_param.map do |name, values|
        values = values.split(',') if values.instance_of?(String)
        [name, values.map { |value| self.class.cast_param(name, value) }.compact]
      end.to_h
    end

    # Downcase all queries before sending to SOLR, except queries
    # which have specific lucene syntax.
    #
    def text_param(text)
      return text.downcase.gsub(/ and | or | not /, &:upcase) unless text.match(/:"/)

      text
    end

    def geo_param(param)
      param.split(',').map(&:to_f)
    end

    def defaults
      {
        geo_bbox: '',
        text: '',
        and: {},
        or: {},
        without: {},
        record_type: 0,
        suggest: 'false',
        solr_query: ''
      }
    end
  end
end
