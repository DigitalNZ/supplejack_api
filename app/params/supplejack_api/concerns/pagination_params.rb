# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module PaginationParams
      attr_reader :page, :per_page, :offset

      private

      def init_pagination(page: 1, per_page: 20, **_)
        @page = integer_param(:page, page.to_i)
        @per_page = integer_param(:per_page, per_page.to_i)
        @offset = (@page * @per_page) - @per_page
      end
    end
  end
end
