# frozen_string_literal: true

module QueryBuilder
  class Spellcheck < Base
    attr_reader :spellcheck

    def initialize(search, spellcheck)
      super(search)

      @spellcheck = spellcheck
    end

    def call
      super
      return search unless spellcheck

      search.build do
        spellcheck collate: true, only_more_popular: true
      end
    end
  end
end
