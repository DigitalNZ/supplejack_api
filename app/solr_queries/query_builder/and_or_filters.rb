# frozen_string_literal: true

module QueryBuilder
  class AndOrFilters < Base
    attr_reader :and_condition, :or_condition, :exclude_filters_from_facets, :facets

    def initialize(search, params)
      super(search)

      @and_condition = params.and_condition
      @or_condition = params.or_condition
      @exclude_filters_from_facets = params.exclude_filters_from_facets
      @facets = params.facets
    end

    # Generates the :and and :or conditions for a search object
    def call
      super

      search.build do
        { and: and_condition, or: or_condition }.each do |operator, value|
          Utils.call_block(self, &recurse_conditions(operator, value))
        end
      end
    end

    private

    # Detects when the key is a operator (:and, :or) and calls itself
    # recursively until it finds facets defined in Sunspot.
    def recurse_conditions(key, conditions, current_operator = :and)
      proc do
        case key.to_sym
        when :and
          all_of do
            conditions.each do |filter, value|
              Utils.call_block(self, &recurse_conditions(filter, value, :and))
            end
          end
        when :or
          any_of do
            conditions.each do |filter, value|
              Utils.call_block(self, &recurse_conditions(filter, value, :or))
            end
          end
        else
          if exclude_filters_from_facets
            Utils.call_block(self, &filter_values(key, conditions, current_operator)) if facets.exclude?(key.to_sym)
          else
            Utils.call_block(self, &filter_values(key, conditions, current_operator))
          end
        end
      end
    end

    # Generates a single condition. It can take an operator to
    # determine how the values within the filter are going to be
    # joined.
    def filter_values(key, conditions, current_operator = :and)
      proc do
        if conditions.is_a? Hash
          operator, values = conditions.first
        else
          operator = current_operator
          values = conditions
        end

        case values
        when Array
          case operator.to_sym
          when :or
            with(key).any_of(values)
          when :and
            with(key).all_of(values)
          else
            raise StandardError, 'Expected operator (:and, :or)'
          end
        when /(.+)\*$/
          with(key).starting_with(Regexp.last_match(1))
        else
          with(key, SupplejackApi::SearchParams.cast_param(key, values))
        end
      end
    end
  end
end
