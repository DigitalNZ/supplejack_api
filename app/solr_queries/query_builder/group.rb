# frozen_string_literal: true

module QueryBuilder
  class Group < Base
    attr_reader :group_by, :group_order_by, :group_sort

    def initialize(search, group_by, group_order_by, group_sort = 'desc')
      super(search)

      @group_by = group_by
      @group_order_by = group_order_by
      @group_sort = group_sort
    end

    def call
      super

    return search if group_by.blank?
      
      search.build do
        group(group_by) do
          order_by(group_order_by, group_sort)
        end
      end
    end
  end
end