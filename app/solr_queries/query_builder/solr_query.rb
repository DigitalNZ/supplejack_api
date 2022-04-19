# frozen_string_literal: true

module QueryBuilder
  class SolrQuery < Base
    attr_reader :query

    def initialize(search, query)
      super(search)

      @query = query
    end

    def call
      super
      return search if query.blank?

      search.build do
        adjust_solr_params do |params|
          params[:q] ||= ''
          params['q.alt'] = query
          params[:defType] = 'dismax'
        end
      end
    end
  end
end
