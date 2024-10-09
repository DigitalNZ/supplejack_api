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
        Utils.call_block(self, &recurse_conditions(:and, and_condition)) if and_condition.present?
        Utils.call_block(self, &recurse_conditions(:or, or_condition)) if or_condition.present?
      end
    end

    private

    # Detects when the key is a operator (:and, :or) and calls itself
    # recursively until it finds facets defined in Sunspot.
    def recurse_conditions(key, conditions, current_operator = :and)
      proc do
        case key.to_sym
        when :and
          all do
            conditions.each { |filter, value| Utils.call_block(self, &recurse_conditions(filter, value, :and)) }
          end
        when :or
          any do
            conditions.each { |filter, value| Utils.call_block(self, &recurse_conditions(filter, value, :or)) }
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

        fulltext_key = fulltext_attr(key)

        case values
        when Array
          case operator.to_sym
          when :or
            fulltext?(key) ? fulltext(values, fields: fulltext_key) : with(key).any_of(values)
          when :and
            fulltext?(key) ? fulltext(values, fields: fulltext_key) : with(key).all_of(values)
          else
            raise StandardError, 'Expected operator (:and, :or)'
          end
        when /(.+)\*$/
          fulltext?(key) ? fulltext(values, fields: fulltext_key) : with(key).starting_with(Regexp.last_match(1))
        else
          casted_value = SupplejackApi::SearchParams.cast_param(key, values)
          fulltext?(key) ? fulltext(casted_value, fields: fulltext_key) : with(key, casted_value)
        end
      end
    end

    def fulltext?(key)
      key.match?(FULLTEXT_REGEXP)
    end

    def fulltext_attr(key)
      key.to_s.gsub(FULLTEXT_REGEXP, '')
    end
  end
end
