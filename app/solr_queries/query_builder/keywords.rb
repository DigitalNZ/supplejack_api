# frozen_string_literal: true

module QueryBuilder
  class Keywords < Base
    attr_reader :text, :query_fields

    def initialize(search, text, query_fields)
      super(search)

      @text = text
      @query_fields = query_fields
    end

    def call
      super
      return search if text.blank?

      search.build do
        keywords text, fields: query_fields
      end
    end
  end
end
