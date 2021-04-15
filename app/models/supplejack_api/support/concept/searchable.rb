# frozen_string_literal: true

module SupplejackApi
  module Support
    module Concept
      module Searchable
        extend ActiveSupport::Concern

        SUNSPOT_TYPE_NAMES = {
          string: :string,
          integer: :integer,
          datetime: :time,
          boolean: :boolean,
          latlon: :latlon
        }.freeze

        included do
          include Sunspot::Mongoid

          searchable do
            build_sunspot_schema(self)
          end
        end

        module ClassMethods
          def custom_find(id, _scope = nil, options = {})
            options ||= {}
            class_scope = unscoped

            case id.to_s
            when /^\d+$/
              data = class_scope.where(concept_id: id.to_i).first
            when /^[0-9a-f]{24}$/i
              data = class_scope.find(id)
            end

            raise Mongoid::Errors::DocumentNotFound.new(self, [id], [id]) unless data

            data
          end

          def build_sunspot_schema(builder)
            ConceptSchema.model_fields.each_value do |field|
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
            end
          end
        end
      end
    end
  end
end
