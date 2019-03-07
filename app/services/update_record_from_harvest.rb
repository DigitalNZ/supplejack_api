# frozen_string_literal: true

# app/services/update_record_from_harvest.rb
class UpdateRecordFromHarvest
  attr_accessor :payload, :preview, :mongo_id, :required_fragments

  def initialize(payload, preview = false, mongo_id = nil, required_fragments = nil)
    @payload = payload
    @preview = preview
    @mongo_id = mongo_id
    @required_fragments = required_fragments
  end

  def call
    internal_identifier = as_single_value(payload['internal_identifier'])

    @record = if mongo_id.present?
                klass.find(mongo_id)
              else
                @record = klass.find_or_initialize_by(internal_identifier: internal_identifier)
              end

    # TODO: probably a meaningless field..
    @record[:source_url] = nil

    target_fragment = select_fragment(@record)

    target_fragment.update(new_fragment_attributes(target_fragment))

    @record.set_status(required_fragments)

    @record.save!

    @record.unset_null_fields

    @record
  end

  private

  # Values from the parser will always come as arrays but they aren't always arrays on the schema.
  def as_single_value(value)
    return value.first if value.is_a?(Array)

    value
  end

  def klass
    return SupplejackApi.config.preview_record_class if preview

    SupplejackApi.config.record_class
  end

  def new_fragment_attributes(fragment)
    schema_fields = SupplejackApi::ApiRecord::RecordFragment.mutable_fields

    attributes_from_payload = payload.each_with_object({}) do |(field_name, field_value), new_attributes|
      next unless schema_fields.key?(field_name)

      new_attributes[field_name] = if schema_fields[field_name.to_s] == Array
                                     field_value
                                   else
                                     as_single_value(field_value)
                                   end
    end

    existing_fragment_attributes_set_to_nil = fragment.raw_attributes.keys.each_with_object({}) do |field_name, existing_attributes|
      next if field_name == 'priority'
      next unless schema_fields.key?(field_name)

      existing_attributes[field_name] = nil
    end

    # nil all mutable fields on primary_fragment except for the priority
    # delete all sub documents on primary fragment

    new_attributes = existing_fragment_attributes_set_to_nil.merge(attributes_from_payload)
    new_attributes['source_id'] = payload['source_id']

    new_attributes
  end

  def select_fragment(record)
    if payload['priority'].to_i.zero? || payload['priority'].nil?
      record.primary_fragment
    else
      record.find_fragment(payload['source_id']) || record.fragments.build
    end
  end
end
