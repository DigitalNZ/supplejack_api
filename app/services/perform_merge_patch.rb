# frozen_string_literal: true

#
# Service for performing a merge patch operation against two Hash objects
#
# Given the following two Hashes
# {a: 1, b: 2, c: {a: 1, b: 2}}
# {b: 1, c: {a: 2}}
#
# The result of performing a merge patch will be
# {a: 1, b: 1, c: {a: 2, b: 2}}
#
# This is designed to be used directly against Mongoid models.
# It confirms that the result of performing the merge operation
# is still a valid model by validating the resultant Hash against
# the passed in Schema.
#
# To generate the JSON from the model for performing the merge patch
# it uses the provided presenter to present the model first.
# This is really only because the schema shape for the Stories API models
# are different from the actual shape of the data storage, so if we
# just extracted the attributes out of the mongo model they
# would not pass the Schema validation
class PerformMergePatch
  attr_reader :schema, :presenter

  # @param schema [Dry::Validation::Schema] used to validate the resulting JSON after a patch is performed
  # @param presenter [#call] used to present the model into the same format the schema expects
  def initialize(schema, presenter)
    @schema = schema
    @presenter = presenter
  end

  # Performs the merge patch using the passed in model and patch hash
  # If the presented model still validates after applying the patch
  # the changes are performed against the model. Any validation errors
  # can be accessed via {#validation_errors}
  #
  # @param model [Mongoid::Document] the model to present and perform the patch against
  # @param patch [Hash] the patch to be applied to the model
  # @return [true, false] whether the schema validated the model after the patch was applied
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

  # Returns full validation messages from the Schema validation
  def validation_errors
    @validation_result&.messages(full: true)
  end
end
