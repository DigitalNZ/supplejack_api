# frozen_string_literal: true

module QueryBuilder
  class MinimumTermFrequency < Base
    attr_reader :frequency

    def initialize(search, frequency)
      super(search)

      @frequency = frequency
    end

    def call
      super

      search.build do
        minimum_term_frequency frequency
      end
    end
  end
end
