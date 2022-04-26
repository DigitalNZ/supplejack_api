# frozen_string_literal: true

module SupplejackApi
  class MltParams
    include SupplejackApi::Concerns::ModelSchemaParams
    include SupplejackApi::Concerns::PaginationParams
    include SupplejackApi::Concerns::FieldsParams
    include SupplejackApi::Concerns::HelpersParams

    attr_reader(
      :frequency,
      :mlt_fields
    )

    class_attribute :max_values

    self.max_values = {
      page: 100_000,
      per_page: 20
    }

    def initialize(**kwargs)
      kwargs = kwargs.reverse_merge!(defaults).symbolize_keys

      init_model_schema_params(**kwargs)
      init_pagination(**kwargs)
      init_fields(**kwargs)

      @frequency = kwargs[:frequency]
      @mlt_fields = mlt_fields_param(kwargs[:mlt_fields])
    end

    private

    # this should also exclude fields with no mlt setup on the schema
    def mlt_fields_param(mlt_fields_str)
      return [] if mlt_fields_str.blank?

      mlt_fields_str.split(',').map { |field| field.strip.to_sym }
    end

    def defaults
      {
        frequency: 1,
        per_page: 5
      }
    end
  end
end
