# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module OrderingParams
      attr_reader :sort, :direction

      private

      def init_ordering(sort: nil, direction: 'desc', **_)
        @sort = sort
        @direction = direction
      end
    end
  end
end
