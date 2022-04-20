# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module FieldsParams
      attr_reader :fields, :group_list, :query_fields

      private

      def init_fields(fields: 'default', query_fields: '', **_)
        @fields = fields_param(fields)
        @group_list = group_list_param(fields)
        @query_fields = query_fields_param(query_fields)
      end

      def fields_param(fields_str)
        valid_fields = schema_class.fields.keys.dup

        field_list = fields_str.split(',').map { |f| f.strip.tr(':', '_').to_sym }
        field_list & valid_fields
      end

      # Returns all valid groups of fields
      # The groups are extracted from the "fields" parameter
      #
      def group_list_param(fields_str)
        group_list = fields_str.split(',').map { |f| f.strip.to_sym }
        group_list & model_class.valid_groups
      end

      def query_fields_param(query_fields)
        query_field_list = []

        case query_fields
        when String
          query_field_list = query_fields.split(',').map(&:strip).map(&:to_sym)
        when Array
          query_field_list = query_fields.map(&:to_sym)
        end

        query_field_list & schema_class.fields.keys
      end
    end
  end
end
