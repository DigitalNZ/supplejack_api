# frozen_string_literal: true
class PerformMergePatch
  attr_reader :schema, :presenter

  def initialize(schema, presenter)
    @schema = schema
    @presenter = presenter
  end

  def call(model, patch)
    presented_model = presenter.call(model)
    merged_attributes = presented_model.deep_merge(patch)
    @validation_result = schema.call(merged_attributes)

    return false unless @validation_result.success?

    merged_attributes.each do |k, v|
      setter_method = "#{k}=".to_sym

      model.send(setter_method, v) if model.respond_to? setter_method
    end

    true
  end

  def validation_errors
    @validation_result&.messages(full: true)
  end
end
