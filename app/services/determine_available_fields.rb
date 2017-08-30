# frozen_string_literal: true

# app/services/determine_available_fields.rb
class DetermineAvailableFields
  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def call
    groups = (options[:groups] & RecordSchema.groups.keys) || []

    fields = RecordSchema.groups.values_at(*groups).flat_map(&:fields).uniq

    fields += options[:fields] if options[:fields].present?

    # These fields are for paging between records
    fields += %i[next_page next_record previous_page previous_record]

    fields
  end
end
