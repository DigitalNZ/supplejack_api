# frozen_string_literal: true
module SupplejackApi::Concerns::RecordSerializable
  extend ActiveSupport::Concern

  # RecordSchema.groups.keys.each do |group|
  #   define_method("#{group}?") do
  #     return false unless options[:groups].try(:any?)
  #     options[:groups].include?(group)
  #   end
  # end

  # There will be something in here that we can use for converting to xml
  # def to_xml(*_args)
  #   serializable_hash.to_xml(root: 'record')
  # end


  # REFACTOR -- Used in concept_serializer.rb too
  # def field_value(field, _options = {})
  #   # So this will find the search value of store is false in the Record Schema DSL
  #   # Otherwise it will just send it to the object (which is the default behaviour of AMS)
  #   value = if RecordSchema.fields[field].try(:search_value) && RecordSchema.fields[field].try(:store) == false
  #             RecordSchema.fields[field].search_value.call(object)
  #           else
  #             object.public_send(field)
  #           end
  #
  #   # If it's nil try the default_value
  #
  #   value = RecordSchema.fields[field].try(:default_value) if value.nil? rescue nil
  #
  #   # Something to do with dates
  #
  #   if RecordSchema.fields[field].try(:date_format)
  #     value = format_date(value, RecordSchema.fields[field].try(:date_format))
  #   end
  #
  #   value
  # end

  # def role
  #   @role ||= options[:scope].role.to_sym rescue nil
  # end
  #
  # def format_date(date, format)
  #   date.strftime(format) rescue date
  # end
  #
  # def role_field_restrictions
  #   restrictions = []
  #
  #   if role && RecordSchema.roles[role] && RecordSchema.roles[role].field_restrictions.present?
  #     restrictions = RecordSchema.roles[role].field_restrictions
  #   end
  #
  #   restrictions
  # end

  # def field_restricted?(conditional_field, condition)
  #   field_values = field_value(conditional_field).to_a
  #   restricted = false
  #
  #   field_values.each do |value|
  #     if (condition.is_a?(Regexp) && value.match(condition)) ||
  #        (condition.is_a?(String) && value.include?(condition))
  #       restricted = true
  #     end
  #     break if restricted
  #   end
  #
  #   restricted
  # end

  # def remove_field_values(restricted_fields, hash)
  #   restricted_fields.each do |field|
  #     hash[field.to_sym] = nil
  #   end
  # end

  # def remove_restricted_fields!(hash)
  #   role_field_restrictions.each do |conditional_field, restrictions|
  #     restrictions.each do |condition, restricted_fields|
  #       if field_restricted?(conditional_field, condition)
  #         remove_field_values(restricted_fields, hash)
  #       end
  #     end
  #   end
  # end


  # # Returns a hash including all desirable record attributes and its associations
  # def serializable_hash
  #   hash = attributes # {}
  #   groups = (options[:groups] & RecordSchema.groups.keys) || [] # potentially [:default]
  #   fields = Set.new # {}
  #
  #   groups.each do |group|
  #     fields.merge(RecordSchema.groups[group].try(:fields)) # merge the fields into the empty set
  #   end
  #
  #   # hash[:id] = field_value(:record_id, options) if fields.any?
  #   # fields.each do |field|
  #   #   hash[field] = field_value(field, options)
  #   # end
  #
  #   # include_individual_fields!(hash)
  #   # remove_restricted_fields!(hash)
  #
  #   hash[:next_page] = object.next_page if object.next_page.present?
  #   hash[:next_record] = object.next_record if object.next_record.present?
  #   hash[:previous_page] = object.previous_page if object.previous_page.present?
  #   hash[:previous_record] = object.previous_record if object.previous_record.present?
  #
  #   hash
  # end

  # def include_individual_fields!(hash)
  #   if options[:fields].present?
  #     options[:fields].each do |field|
  #       hash[field] = record.send(field)
  #     end
  #   end
  #
  #   hash
  # end
end
