# frozen_string_literal: true

module QueryBuilder
  class Ordering < Base
    attr_reader :model_class, :order_by, :order_direction

    def initialize(search, schema_class, model_class, order_by, order_direction)
      super(search)

      @order_by = order_by
      @model_class = model_class
      @schema_class = schema_class
      @order_direction = order_direction
    end

    def call
      super
      return search if order_by.blank?

      this = self
      search.build do
        order_by(this.order_by_attribute, this.direction)
      end
    end

    def order_by_attribute
      value = @schema_class.fields[@order_by&.to_sym]
      value = @schema_class.fields["sort_#{value.name}".to_sym] if value.multi_value

      begin
        Sunspot::Setup.for(model_class).field(value.name)
        value.name
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