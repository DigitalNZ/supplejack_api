# frozen_string_literal: true

module SupplejackApi
  class MltParams < BaseParams
    attr_reader(
      :exclude_filters_from_facets,
      :facets,
      :frequency,
      :mlt_fields,
      :and_condition,
      :or_condition,
      :record_type,
      :debug
    )

    class_attribute :max_values

    self.max_values = {
      page: 10_000,
      per_page: 100
    }

    def initialize(**kwargs)
      super(**kwargs)

      init_model_schema_params(**@params)
      init_pagination(**@params)
      init_ordering(**@params)
      init_fields(**@params)
      init_geo_bbox(**@params)
      init_without(**@params)

      @frequency = @params[:frequency]
      @mlt_fields = mlt_fields_param(@params[:mlt_fields])
      @and_condition = @params[:and]
      @or_condition = @params[:or]
      @record_type = @params[:record_type]

      @debug = kwargs[:debug] == 'true'
    end

    def valid?
      errors.empty?
    end

    private

    # transform the string into array and selects only the fields which can
    # be searched as mlt
    def mlt_fields_param(mlt_fields_str)
      return [] if mlt_fields_str.blank?

      fields = mlt_fields_str.split(',').map { |field| field.strip.to_sym }
      fields.select { |field| RecordSchema.fields[field]&.search_as&.include?(:mlt) }
    end

    def defaults
      {
        frequency: 1,
        per_page: 5,
        and: {},
        or: {},
        record_type: 0
      }
    end
  end
end
