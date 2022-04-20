# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module ModelSchemaParams
      attr_reader :model_class, :schema_class

      private

      # this needs to be called first for the fields and facets params to work
      def init_model_schema_params(model_class:, schema_class:, **_)
        @model_class = model_class
        @schema_class = schema_class
      end
    end
  end
end
