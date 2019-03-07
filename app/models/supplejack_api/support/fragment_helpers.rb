# frozen_string_literal: true

module SupplejackApi
  module Support
    module FragmentHelpers
      extend ActiveSupport::Concern

      included do
        validate :validate_unique_source_ids
      end

      def source_ids
        fragments.map(&:source_id)
      end

      def duplicate_source_ids?
        source_ids.size != fragments.distinct(:source_id).count
      end

      def validate_unique_source_ids
        return unless duplicate_source_ids?

        errors.add(:base, "fragment source_ids must be unique, source_ids: #{source_ids}")
        klass_name = fragment_class.to_s.demodulize.gsub(/Fragment/, '')
        klass_id = "#{klass_name.downcase}_id"
        log_message = "#{klass_name} with #{klass_id}:#{send(klass_id)},"
        log_message += " internal_identifier:#{internal_identifier} failed validation."
        log_message += "  Fragment source_ids must be unique, source_ids: #{source_ids}"
        ValidationLogger.logger.error(log_message)
      end

      def primary_fragment(attributes = {})
        primary = fragments.where(priority: 0).first
        primary ? primary : fragments.build(attributes.merge(priority: 0))
      end

      def primary_fragment!(attributes = {})
        primary_fragment(attributes).tap(&:save)
      end

      def merge_fragments
        self.merged_fragment = nil
        return if fragments.size == 1

        new_fragment_attributes = fragment_class.mutable_fields.each_with_object({}) do |(field_name, field_type), attributes|
          if field_type == Array
            attributes[field_name] = []

            sorted_fragments.each do |fragment|
              next if fragment[field_name].nil?

              attributes[field_name] += fragment[field_name]
            end

            attributes[field_name].uniq!
          else
            attributes[field_name] = sorted_fragments.to_a.map { |fragment| fragment[field_name] }.compact.first
          end
        end

        new_fragment_attributes.reject! { |_key, value| (value.nil? && value != priority) || value == [] }

        # This is done after we have cleared the other nil values as otherwise it will fallback to a default value
        new_fragment_attributes['priority'] = nil

        self.merged_fragment = fragment_class.new(new_fragment_attributes)
      end

      # Fetch the attribute from the underlying
      # merged_fragment or only fragment.
      # Means that record.{attribute} (ie. record.name) works for convenience
      # and abstracts away the fact that fragments exist
      # rubocop:disable Style/MethodMissing
      def method_missing(symbol, *_args)
        type = fragment_class.mutable_fields[symbol.to_s]

        if merged_fragment
          value = merged_fragment.public_send(symbol)
        elsif fragments.first
          value = fragments.first.public_send(symbol)
        end
        type == Array ? Array(value) : value
      end
      # rubocop:enable Style/MethodMissing

      def sorted_fragments
        fragments.sort_by { |s| s.priority || Integer::INT32_MAX }
      end

      def find_fragment(source_id)
        fragments.where(source_id: source_id).first
      end
    end
  end
end
