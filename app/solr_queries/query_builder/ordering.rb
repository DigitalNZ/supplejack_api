# frozen_string_literal: true

module QueryBuilder
  class Ordering < Base
    attr_reader :model_class, :order_by, :order_direction

    def initialize(search, model_class, order_by, order_direction)
      super(search)

      @order_by = order_by
      @model_class = model_class
      @order_direction = order_direction
    end

    def call
      super
      return search if order_by.blank?

      model_class = self
      search.build do
        order_by(model_class.order_by_attribute, model_class.direction)
      end
    end

    def order_by_attribute
      value = order_by.to_sym

      begin
        Sunspot::Setup.for(model_class).field(value)
        value
      rescue Sunspot::UnrecognizedFieldError
        :score
      end
    end

    def direction
      if %w[asc desc].include?(order_direction)
        order_direction.to_sym
      else
        :desc
      end
    end
  end
end
