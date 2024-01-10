# frozen_string_literal: true

module QueryBuilder
  class Paginate < Base
    attr_reader :page, :per_page

    def initialize(search, page, per_page)
      super(search)

      @page = page
      @per_page = per_page
    end

    def call
      super

      search.build do
        paginate page:, per_page:
      end
    end
  end
end
