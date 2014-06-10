# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RecordSerializer < ActiveModel::Serializer

    RecordSchema.groups.keys.each do |group|
      define_method("#{group}?") do
        return false unless options[:groups].try(:any?)
        self.options[:groups].include?(group)
      end
    end

    # Returns a hash including all desirable record attributes and its associations
    def serializable_hash
      hash = attributes

      groups = (options[:groups] & RecordSchema.groups.keys) || []

      fields = Set.new
      groups.each do |group|
        fields.merge(RecordSchema.groups[group].try(:fields))
      end

      # hash[:id] = field_value(:record_id, options) if fields.any?

      fields.each do |field|
        hash[field] = field_value(field, options)
      end

      # include_individual_fields!(hash)
      remove_restricted_fields!(hash)

      hash[:next_page] = object.next_page if object.next_page.present?
      hash[:next_record] = object.next_record if object.next_record.present?
      hash[:previous_page] = object.previous_page if object.previous_page.present?
      hash[:previous_record] = object.previous_record if object.previous_record.present?
      hash
    end

    def to_xml(*args)
      serializable_hash.to_xml(root: "record")
    end

    # def include_individual_fields!(hash)
    #   if self.options[:fields].present?
    #     self.options[:fields].each do |field|
    #       hash[field] = record.send(field)
    #     end
    #   end
    #   hash
    # end

    def remove_restricted_fields!(hash)
      role_field_restrictions.each do |conditional_field, restrictions|
        restrictions.each do |condition, restricted_fields|
          if field_restricted?(conditional_field, condition)
            remove_field_values(restricted_fields, hash)
         end
       end
     end
    end

    # REFACTOR -- Used in concept_serializer.rb too
    def field_value(field, options={})
      value = nil
      if RecordSchema.fields[field].try(:search_value) && RecordSchema.fields[field].try(:store) == false
        value = RecordSchema.fields[field].search_value.call(object)
      else
        value = object.public_send(field)
      end

      value
    end

    def role
      @role ||= options[:scope].role.to_sym rescue nil
    end

    private

    def role_field_restrictions
      restrictions = []

      if role && RecordSchema.roles[role] && RecordSchema.roles[role].field_restrictions.present?
        restrictions = RecordSchema.roles[role].field_restrictions
      end

      restrictions
    end

    def field_restricted?(conditional_field, condition)
      field_values = self.field_value(conditional_field).to_a
      restricted = false

      field_values.each do |value|
        if (condition.is_a?(Regexp) && value.match(condition)) ||
          (condition.is_a?(String) && value.include?(condition))
          restricted = true
        end
        break if restricted
      end

      restricted
    end

    def remove_field_values(restricted_fields, hash)
      restricted_fields.each do |field|
        hash[field.to_sym] = nil
      end
    end

  end

end
