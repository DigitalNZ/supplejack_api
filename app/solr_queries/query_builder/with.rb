# frozen_string_literal: true

module QueryBuilder
  class With < Base
    attr_reader :included_hash

    def initialize(search, included_hash)
      super(search)

      @included_hash = included_hash
    end

    def call
      super
      return search if included_hash.blank?

      search.build do
        included_hash.each do |field, values|
          with(field.to_sym, values)
        end
      end
    end
  end
end
