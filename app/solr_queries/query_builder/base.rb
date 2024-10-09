# frozen_string_literal: true

module QueryBuilder
  class Base
    FULLTEXT_REGEXP = /_textv?$/

    attr_reader :search, :this

    def initialize(search)
      @search = search
    end

    def call
      @this = self
    end

    def cast_param(_name, value)
      return false if value == 'false'
      return true if value == 'true'
      return nil if %w[nil null].include?(value)

      value = value.strip if value.is_a?(String)
      value
    end
  end
end
