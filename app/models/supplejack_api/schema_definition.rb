# frozen_string_literal: true

module SupplejackApi
  module SchemaDefinition
    extend ActiveSupport::Concern

    SCHEMA_METHODS = %i[string integer datetime boolean latlon text].freeze
    ALLOWED_ATTRIBUTES = {
      field: %i[type search_value search_boost multi_value facet_method search_as store
                solr_name namespace namespace_field default_value date_format merge_as_single_value],
      group: %i[fields includes],
      role: %i[default field_restrictions record_restrictions admin harvester anonymous],
      namespace: [:url],
      mongo_index: %i[fields index_options],
      model_field: %i[type field_options validation index_fields index_options
                      search_value search_as store namespace]
    }.freeze

    included do
      cattr_accessor :fields, :groups, :roles, :default_role, :namespaces, :mongo_indexes, :model_fields
    end

    module ClassMethods
      SCHEMA_METHODS.each do |type|
        define_method(type) do |*args, &block|
          field(type, *args, &block)
        end
      end

      private

      def field(type, name, options = {}, &block)
        self.fields ||= {}
        options[:type] = type

        field = Field.new(name, options, &block)
        self.fields[name] = field

        # This is so we have a string alternative of an integer and date fields that can be used for facetting.
        str_types = %i[integer datetime]
        field(:string, "#{name}_str", options.merge(type: :string), &block) if str_types.include? type
      end

      def group(name, options = {}, &block)
        self.groups ||= {}

        group = Group.new(name, options, &block)
        group.include_groups_from(groups)

        self.groups[name] = group
      end

      def role(name, options = {}, &block)
        self.roles ||= {}

        role = Role.new(name, options, &block)
        self.default_role = role if role.default

        self.roles[name] = role
      end

      def namespace(name, options = {})
        self.namespaces ||= {}

        namespace = Namespace.new(name, options)
        self.namespaces[name] = namespace
      end

      def mongo_index(name, options = {})
        self.mongo_indexes ||= {}

        mongo_index = MongoIndex.new(name, options)
        self.mongo_indexes[name] = mongo_index
      end

      def model_field(name, options = {}, &block)
        self.model_fields ||= {}

        model_field = ModelField.new(name, options, &block)
        self.model_fields[name] = model_field
      end
    end

    class SchemaObject
      ALLOWED_ATTRIBUTES = ALLOWED_ATTRIBUTES.values.flatten

      attr_reader :name

      def initialize(name, options, &block)
        @name = name

        builder = SchemaObjectBuilder.new(options)
        builder.instance_eval(&block) if block_given?

        @options = builder.options
      end

      ALLOWED_ATTRIBUTES.each do |attr|
        define_method(attr) do
          @options[attr]
        end
      end

      class SchemaObjectBuilder
        attr_reader :options

        def initialize(options)
          @options = options
        end

        ALLOWED_ATTRIBUTES.each do |attr|
          define_method(attr) do |*args, &block|
            @options[attr] = block || args.first
          end
        end
      end
    end

    class Field < SchemaObject
      def namespace_field
        namespace_field = !!@options[:namespace_field] ? @options[:namespace_field] : @name
      end
    end

    class Namespace < SchemaObject
    end

    class Group < SchemaObject
      def include_groups_from(existing_groups)
        return if @options[:includes].blank?

        included_fields = @options[:includes].collect { |g| existing_groups[g].fields }
        @options[:fields] = included_fields.flatten | @options[:fields]
      end
    end

    class Role < SchemaObject
    end

    class MongoIndex < SchemaObject
    end

    class ModelField < SchemaObject
    end
  end
end
