# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module SchemaDefinition
    extend ActiveSupport::Concern

    ALLOWED_ATTRIBUTES = {
      field: [:type, :search_value, :search_boost, :multi_value, :search_as, :store, :solr_name, :namespace],
      group: [:fields, :includes],
      role: [:default, :field_restrictions, :record_restrictions],
      namespace: [:url]
    }

    included do
      cattr_accessor :fields, :groups, :roles, :default_role, :namespaces
    end

    module ClassMethods
      [:string, :integer, :datetime, :boolean].each do |type|
        define_method(type) do |*args, &block|
          field(type, *args, &block)
        end
      end

      private

      def field(type, name, options={}, &block)
          self.fields ||= {}
          options.merge!(type: type)

          # Add the namespace as a prefix to the field name
          if options[:namespace].present?
            namespace = options[:namespace]
            unless self.namespaces.keys.include?(namespace)
              Rails.logger.warn("Namespace [#{options[:namespace]}] is not defined. Available namespaces are [#{self.namespaces.keys}]")
              puts "WARN: Namespace [#{options[:namespace]}] is not defined. Available namespaces are [#{self.namespaces.keys}]"
            end

            name = "#{namespace}_#{name}".to_sym
          end

          field = Field.new(name, options, &block)
          self.fields[name] = field
      end

      def group(name, options={}, &block)
        self.groups ||= {}

        group = Group.new(name, options, &block)
        group.include_groups_from(groups)

        self.groups[name] = group
      end

      def role(name, options={}, &block)
        self.roles ||= {}

        role = Role.new(name, options, &block)
        if role.default
          self.default_role = role
        end

        self.roles[name] = role
      end

      def namespace(name, options={}, &block)
        self.namespaces ||= {}

        namespace = Namespace.new(name, options)
        self.namespaces[name] = namespace
      end
    end

    class SchemaObject
      ALLOWED_ATTRIBUTES = ALLOWED_ATTRIBUTES.values.flatten

      attr_reader :name

      def initialize(name, options, &block)
        @name = name

        builder = SchemaObjectBuilder.new(options)
        if block_given?
          builder.instance_eval(&block)
        end

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
    end

    class Namespace < SchemaObject
    end  

    class Group < SchemaObject
      def include_groups_from(existing_groups)
        if @options[:includes].present?
          included_fields = @options[:includes].collect { |g| existing_groups[g].fields }
          @options[:fields] = included_fields.flatten | @options[:fields]
        end
      end
    end

    class Role < SchemaObject
    end

  end
end
