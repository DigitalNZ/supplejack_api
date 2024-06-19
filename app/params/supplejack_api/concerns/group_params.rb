# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module GroupParams
      attr_reader :group_by, :group_order_by, :group_sort

      private

      def init_group(group_by: nil, group_order_by: nil, group_sort: 'desc', **_)
        @group_by = group_by
        @group_order_by = group_order_by
        @group_sort = group_sort
      end
    end
  end
end
