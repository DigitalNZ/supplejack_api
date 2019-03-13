# frozen_string_literal: true

module SupplejackApi
  module Support
    module Harvestable
      extend ActiveSupport::Concern

      def set_status(required_fragments)
        missing_fragments = Array(required_fragments) - fragments.map(&:source_id)
        self.status = missing_fragments.empty? ? 'active' : 'partial'
      end

      def unset_null_fields
        raw_json = raw_attributes || {}
        unset_hash = {}
        raw_json.each do |key, value|
          unset_hash.merge!(key => true) if value.nil?
        end
        if raw_json['fragments'].present?
          raw_json['fragments'].each_with_index do |fragment, index|
            next if fragment.nil?

            fragment.each do |key, value|
              unset_hash.merge!("fragments.#{index}.#{key}" => true) if value.nil?
            end
          end
        end
        collection.find(atomic_selector).update_one('$unset' => unset_hash) if unset_hash.any?
      end

      module ClassMethods
        def find_or_initialize_by_identifier(attributes)
          identifier = attributes.delete(:internal_identifier)
          identifier = identifier.first if identifier.is_a?(Array)
          find_or_initialize_by(internal_identifier: identifier)
        end
      end
    end
  end
end
