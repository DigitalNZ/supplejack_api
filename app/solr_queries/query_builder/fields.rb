# frozen_string_literal: true

module QueryBuilder
  class Fields < Base
    attr_reader :fields_array

    def initialize(search, fields)
      super(search)

      @fields_array = fields
    end

    def call
      super

      search.build do
        fields(*fields_array)
      end
    end
  end
end
