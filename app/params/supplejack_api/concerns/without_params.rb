# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module WithoutParams
      attr_reader :without, :without_fulltext

      private

      def init_without(without: {}, **_)
        @without = {}
        @without_fulltext = {}
        without.each do |field, values|
          values = cast_values(field, values)
          field = build_field(field)
          add_field(field, values)
        end
      end

      def cast_values(field, values)
        values = values.split(',') if values.instance_of?(String)
        values.map { |value| self.class.cast_param(field, value) }.compact
      end

      def build_field(field)
        return { key: :normal, value: field } if field.to_s.in?(schema_class.fields.keys.map(&:to_s))

        field = field.gsub(QueryBuilder::Base::FULLTEXT_REGEXP, '')
        field = Sunspot::Setup.for(model_class).text_fields(field).first.indexed_name
        { key: :fulltext, value: field }
      rescue Sunspot::UnrecognizedFieldError
        nil
      end

      def add_field(field, values)
        return if field.nil?

        is_fulltext = field[:key] == :fulltext
        field_name = field[:value]

        if is_fulltext
          @without_fulltext[field_name] = values
        else
          @without[field_name] = values
        end
      end
    end
  end
end
