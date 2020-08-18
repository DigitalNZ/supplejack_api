# frozen_string_literal: true

module SupplejackApi
  module Support
    module Searchable
      extend ActiveSupport::Concern

      included do
        include Sunspot::Mongoid

        searchable if: :should_index? do
          string :internal_identifier
          integer :record_type

          string :source_id do
            primary_fragment.source_id
          end

          build_sunspot_schema(self)
        end
      end

      SUNSPOT_TYPE_NAMES = {
        string: :string,
        integer: :integer,
        datetime: :time,
        boolean: :boolean,
        latlon: :latlon
      }.freeze

      module ClassMethods
        def schema_class
          "#{to_s.demodulize}Schema".constantize
        end

        def custom_find(id, scope = nil, options = {})
          options ||= {}
          class_scope = unscoped
          class_scope = class_scope.active unless options.delete(:status) == :all

          # .to_sym prevents Brakeman complaining about possible SQL injection
          column = "#{name.demodulize.downcase}_id".to_sym

          if id.to_s =~ /^\d+$/
            data = class_scope.where(column => id.to_i).first
          elsif id.to_s =~ /^[0-9a-f]{24}$/i
            data = class_scope.find(id)
          end

          raise Mongoid::Errors::DocumentNotFound.new(self, [id], [id]) unless data

          begin
            data.find_next_and_previous_records(scope, options) if options.any?
          rescue Sunspot::UnrecognizedFieldError,
                 RSolr::Error::Http, Timeout::Error,
                 Errno::ECONNREFUSED,
                 Errno::ECONNRESET => e

            Rails.logger.error e.inspect
          end

          data
        end

        def build_sunspot_schema(builder)
          schema_class.fields.each_value do |field|
            options = {}
            search_as = field.search_as || []

            value_block = nil
            if field.search_value.present?
              value_block = proc do
                field.search_value.call(self)
              end
            end

            options[:as] = field.solr_name if field.solr_name.present?

            if search_as.include? :filter
              filter_options = {}
              filter_options[:multiple] = true if field.multi_value.present?
              type = SUNSPOT_TYPE_NAMES[field.type]

              builder.public_send(type, field.name, options.merge(filter_options), &value_block)
            end

            if search_as.include? :fulltext
              options[:boost] = field.search_boost if field.search_boost.present?
              builder.text field.name, options, &value_block
            end

            if search_as.include? :mlt
              options[:more_like_this] = true
              builder.text field.name, options, &value_block
            end
          end
        end

        def valid_facets
          facets = []

          schema_class.fields.each do |name, field|
            search_as = field.search_as || []
            facets << name.to_sym if search_as.include? :filter
          end

          facets
        end

        def valid_groups
          schema_class.groups.keys
        end
      end
    end
  end
end
