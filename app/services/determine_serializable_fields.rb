# frozen_string_literal: true

# app/services/determine_serializable_fields.rb
class DetermineSerializableFields
  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def call
    groups = (options[:groups] & RecordSchema.groups.keys) || []

    fields = RecordSchema.groups.values_at(*groups).flat_map(&:fields).uniq

    fields += options[:fields] if options[:fields].present?

    fields
  end
end
