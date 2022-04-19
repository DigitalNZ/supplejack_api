# frozen_string_literal: true

module QueryBuilder
  class RecordType < Base
    attr_reader :record_type

    def initialize(search, record_type)
      super(search)

      @record_type = record_type
    end

    def call
      super

      search.build do
        with(:record_type, record_type) unless record_type == 'all'
      end
    end
  end
end
