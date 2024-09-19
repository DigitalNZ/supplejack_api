# frozen_string_literal: true

module QueryBuilder
  class WithoutFulltext < Base
    attr_reader :without_hash

    def initialize(search, without_hash)
      super(search)

      @without_hash = without_hash
    end

    def call
      super
      return search if without_hash.blank?

      search.build do
        adjust_solr_params do |params|
          params[:fq] ||= []
          without_hash.each do |field, values|
            params[:fq] << "-#{field}:(#{values.join(' OR ')})"
          end
        end
      end
    end
  end
end
