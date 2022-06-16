# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module SupplejackApi
  class Search
    attr_accessor :options, :request_url, :scope, :solr_request_params, :errors, :warnings

    alias read_attribute_for_serialization send

    def initialize(options = {})
      @original_options = options.dup
      @options = SearchParams.new(
        **options.merge(model_class: self.class.model_class, schema_class: self.class.schema_class)
      )
    end

    def self.model_class
      to_s.gsub(/Search/, '').constantize
    end

    def self.schema_class
      "#{model_class.to_s.demodulize}Schema".constantize
    end

    def valid?
      self.errors ||= []
      self.warnings ||= []
      options.max_values.each_key do |attribute|
        max_value = options.max_values[attribute]
        if @original_options[attribute].to_i > max_value
          self.errors << "The #{attribute} parameter can not exceed #{max_value}"
        end
      end

      # This error comes from search_builder method.
      # If i am to handle it there i will have to modify all the methods
      # between solr_search_object and search builder. So handling it here
      begin
        solr_search_object
      rescue Sunspot::UnrecognizedFieldError => e
        errors << e.message
      end

      self.errors.empty?
    end

    def solr_search_object
      return @solr_search_object if @solr_search_object

      @solr_search_object = execute_solr_search

      if options.debug && @solr_search_object.respond_to?(:query)
        self.solr_request_params = @solr_search_object.query.to_params
      end

      @solr_search_object
    end

    # QUESTION: Can this method be private?
    # If not, spec it
    def execute_solr_search
      search = search_builder

      self.errors ||= []
      sunspot = search.execute
    rescue RSolr::Error::Http => e
      self.errors << e
      Rails.logger.info self.errors
      sunspot = {}
    ensure
      sunspot
    end

    # The records that match the criteria within each role will be removed
    # from the search results
    #
    def self.role_collection_restrictions(scope)
      role = scope&.role&.to_sym
      return [] if scope.blank? || schema_class.roles[role].record_restrictions.blank?

      schema_class.roles[role].record_restrictions
    end

    # rubocop:disable Metrics/AbcSize
    def search_builder
      return @search_builder if @search_builder.present?

      @search_builder ||= Sunspot.new_search(SupplejackApi::Record)

      @search_builder = QueryBuilder::RecordType.new(@search_builder, options.record_type).call
      @search_builder = QueryBuilder::Facets.new(@search_builder, options).call
      @search_builder = QueryBuilder::Spellcheck.new(@search_builder, options.suggest).call
      @search_builder = QueryBuilder::Without.new(@search_builder, options.without).call
      @search_builder = QueryBuilder::WithBoudingBox.new(@search_builder, options.geo_bbox).call
      @search_builder = QueryBuilder::SolrQuery.new(@search_builder, options.solr_query).call
      @search_builder = QueryBuilder::FacetPivot.new(@search_builder, options.facet_pivots).call
      @search_builder = QueryBuilder::Defaults.new(@search_builder).call
      @search_builder = QueryBuilder::FacetRow.new(@search_builder, options.facet_query).call
      @search_builder = QueryBuilder::Ordering.new(
        @search_builder, RecordSchema, SupplejackApi::Record, options.sort, options.direction
      ).call

      restrictions = self.class.role_collection_restrictions(scope)
      @search_builder = QueryBuilder::Without.new(@search_builder, restrictions).call

      suppressed_source_ids = SupplejackApi::Source.suppressed.all.pluck(:source_id)
      @search_builder = QueryBuilder::Without.new(@search_builder, source_id: suppressed_source_ids).call

      @search_builder = QueryBuilder::ExcludeFiltersFromFacets.new(@search_builder, options).call
      @search_builder = QueryBuilder::Paginate.new(@search_builder, options.page, options.per_page).call
      @search_builder.build(&build_conditions)
      @search_builder = QueryBuilder::Keywords.new(@search_builder, options.text, options.query_fields).call

      @search_builder
    end
    # rubocop:enable Metrics/AbcSize

    # Returns the facets part of the search results converted to a hash
    #
    # @return [Hash] facets in hash form, each facet is respresented as +facet_name => facet_values+
    def facets_hash
      facets = {}

      self.facets.each do |facet|
        rows = {}
        facet.rows.each do |row|
          rows[row.value] = row.count
        end

        facets.merge!(facet.name => rows)
      end

      facets
    end

    def records
      solr_search_object.results
    end

    def method_missing(symbol, *args)
      return nil unless solr_search_object.respond_to?(:hits)

      solr_search_object.send(symbol, *args)
    end

    private

    # Generates the :and and :or conditions for a search object
    #
    def build_conditions
      proc do
        { and: options.and_condition, or: options.or_condition }.each do |operator, value|
          Utils.call_block(self, &recurse_conditions(operator, value))
        end
      end
    end

    # Detects when the key is a operator (:and, :or) and calls itself
    # recursively until it finds facets defined in Sunspot.
    #
    def recurse_conditions(key, conditions, current_operator = :and)
      proc do
        case key.to_sym
        when :and
          all_of do
            conditions.each do |filter, value|
              Utils.call_block(self, &recurse_conditions(filter, value, :and))
            end
          end
        when :or
          any_of do
            conditions.each do |filter, value|
              Utils.call_block(self, &recurse_conditions(filter, value, :or))
            end
          end
        else
          if options.exclude_filters_from_facets
            if options.facets.exclude?(key.to_sym)
              Utils.call_block(self, &filter_values(key, conditions, current_operator))
            end
          else
            Utils.call_block(self, &filter_values(key, conditions, current_operator))
          end
        end
      end
    end

    # Generates a single condition. It can take a operator to
    # determine how the values within the filter are going to be
    # joined.
    #
    def filter_values(key, conditions, current_operator = :and)
      proc do
        if conditions.is_a? Hash
          operator, values = conditions.first
        else
          operator = current_operator
          values = conditions
        end

        case values
        when Array
          case operator.to_sym
          when :or
            with(key).any_of(values)
          when :and
            with(key).all_of(values)
          else
            raise StandardError, 'Expected operator (:and, :or)'
          end
        when /(.+)\*$/
          with(key).starting_with(Regexp.last_match(1))
        else
          with(key, SearchParams.cast_param(key, values))
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
