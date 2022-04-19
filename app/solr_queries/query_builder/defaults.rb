# frozen_string_literal: true

module QueryBuilder
  class Defaults < Base
    def call
      super

      search.build do
        adjust_solr_params do |params|
          params['q.op'] = 'AND'
          params['df'] = 'text'
          params['sow'] = 'true'
          params['facet.threads'] = ENV['SOLR_FACET_THREADS']&.to_i || 4
        end
      end
    end
  end
end
