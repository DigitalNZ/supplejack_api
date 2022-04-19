# frozen_string_literal: true

module QueryBuilder
  class Without < Base
    attr_reader :without_hash

    def initialize(search, without_hash)
      super(search)

      @without_hash = without_hash
    end

    def call
      super
      return search if without_hash.blank?

      search.build do
        without_hash.each do |field, values|
          without(field.to_sym, values)
        end
      end
    end
  end
end
