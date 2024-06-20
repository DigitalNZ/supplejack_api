# frozen_string_literal: true

module QueryBuilder
  class Group < Base
    attr_reader :group_by, :group_order_by

    VALID_SORTING_OPTIONS = %w[asc desc].freeze

    def initialize(search, group_by, group_order_by, group_sort = 'desc')
      super(search)

      @group_by = group_by
      @group_order_by = group_order_by
      @group_sort = group_sort
    end

    def call
      super

      return search if group_by.blank? && group_order_by.blank?

      search.build do
        group(group_by) do
          order_by(group_order_by, group_sort)
        end
        
        # this flag means that the facet counts reflect the groupings, rather than the number of records in a group
        adjust_solr_params do |params|
          params['group.facet'] = true
        end
      end
    end

    private

    def group_sort
      return @group_sort if VALID_SORTING_OPTIONS.include?(@group_sort)

      'desc'
    end
  end
end
