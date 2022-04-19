# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module SupplejackApi
  class Search
    def initialize(options = {})
      @options = options.dup
      @options.reverse_merge!(
        facets: '',
        facet_pivots: '',
        and: {},
        or: {},
        without: {},
        page: 1,
        per_page: 20,
        record_type: 0,
        facets_per_page: 10,
        facets_page: 1,
        sort: nil,
        direction: 'desc',
        exclude_filters_from_facets: false,
        fields: 'default',
        facet_query: {},
        debug: nil
      )
    end

    def self.model_class
      to_s.gsub(/Search/, '').constantize
    end

    def self.schema_class
      "#{model_class.to_s.demodulize}Schema".constantize
    end

    # Return an array of valid facets
    # It will remove any invalid facets in order to avoid Solr errors
    #
    def facet_list
      facet_list = options[:facets].split(',').map { |f| f.strip.to_sym }
      facet_list.keep_if { |f| self.class.model_class.valid_facets.include?(f) }

      # This is to prevent users from requesting integer and date fields as facets
      # because we do not have docValues built up for these fields faceting does not work.
      # We do not have docValues because we are experiencing an issue with the facet counts being wrong
      # between different Solr replicas.
      str_facets = %i[integer datetime]
      facet_list.map do |facet|
        if str_facets.include?(RecordSchema.fields[facet].type)
          "#{facet}_str".to_sym
        else
          facet
        end
      end
    end

    def facet_pivot_list
      return '' if options[:facet_pivots].blank?
      return @facet_pivot_list if @facet_pivot_list

      @facet_pivot_list =
        options[:facet_pivots].split(',').map do |field|
          field_facet = Sunspot.search(SupplejackApi::Record) do
            json_facet(field.to_sym)
          end.facets.first

          field_facet.instance_eval('@field', __FILE__, __LINE__).indexed_name
        rescue Sunspot::UnrecognizedFieldError
          nil
        end.compact.join(',')
    end

    def field_list
      return @field_list if @field_list

      valid_fields = self.class.schema_class.fields.keys.dup

      @field_list = options[:fields].split(',').map { |f| f.strip.tr(':', '_').to_sym }
      @field_list.delete_if do |f|
        !valid_fields.include?(f)
      end

      @field_list
    end

    # Returns all valid groups of fields
    # The groups are extracted from the "fields" parameter
    #
    def group_list
      return @group_list if @group_list

      @group_list = options[:fields].split(',').map { |f| f.strip.to_sym }
      @group_list.keep_if { |f| self.class.model_class.valid_groups.include?(f) }
      @group_list
    end

    def query_fields
      query_field_list = nil

      case options[:query_fields]
      when String
        query_field_list = options[:query_fields].split(',').map(&:strip).map(&:to_sym)
      when Array
        query_field_list = options[:query_fields].map(&:to_sym)
      end

      return nil if query_field_list&.empty?

      query_field_list
    end

    def extract_range(value)
      if value =~ /^\[(\d+)\sTO\s(\d+)\]$/
        Regexp.last_match(1).to_i..Regexp.last_match(2).to_i
      else
        value.to_i.positive? ? value.to_i : value.strip
      end
    end

    def to_proper_value(_name, value)
      return false if value == 'false'
      return true if value == 'true'
      return nil if %w[nil null].include?(value)

      value = value.strip if value.is_a?(String)
      value
    end

    # Downcase all queries before sending to SOLR, except queries
    # which have specific lucene syntax.
    #
    def text
      @text = options[:text]

      if @text.present? && !@text.match(/:"/)
        @text = @text.downcase
        @text.gsub!(/ and | or | not /, &:upcase)
      end

      @text
    end

    def valid?
      self.errors ||= []
      self.warnings ||= []
      self.class.max_values.each_key do |attribute|
        max_value = self.class.max_values[attribute]
        self.errors << "The #{attribute} parameter can not exceed #{max_value}" if @options[attribute].to_i > max_value
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

      if options[:debug] == 'true' && @solr_search_object.respond_to?(:query)
        self.solr_request_params = @solr_search_object.query.to_params
      end

      @solr_search_object
    end

    # QUESTION: Can this method be private?
    # If not, spec it
    def execute_solr_search
      search = search_builder
      search = QueryBuilder::Keywords.new(search, text, query_fields).call

      self.errors ||= []
      sunspot = search.execute
    rescue RSolr::Error::Http => e
      self.errors << e
      Rails.logger.info self.errors
      sunspot = {}
    ensure
      sunspot
    end

    INTEGER_ATTRIBUTES ||= %i[page per_page facets_per_page facets_page record_type].freeze
    alias read_attribute_for_serialization send

    attr_accessor :options, :request_url, :scope, :solr_request_params, :errors, :warnings

    class_attribute :max_values

    self.max_values = {
      page: 100_000,
      per_page: 100,
      facets_per_page: 350,
      facets_page: 5000
    }

    # The records that match the criteria within each role will be removed
    # from the search results
    #
    def self.role_collection_restrictions(scope)
      restrictions = []

      if scope
        role = scope.role&.to_sym
        restrictions = schema_class.roles[role].record_restrictions if schema_class.roles[role].record_restrictions
      end

      restrictions
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # FIXME: Make this method smaller, it's triple the max method length
    def search_builder
      search_model = self

      @search_builder ||= Sunspot.new_search(SupplejackApi::Record)

      @search_builder = QueryBuilder::ExcludeFiltersFromFacets.new(
        @search_builder, options[:exclude_filters_from_facets], options[:and],
        options[:or], facet_list, facets_per_page, facets_offset
      ).call
      @search_builder = QueryBuilder::Defaults.new(@search_builder).call
      @search_builder = QueryBuilder::RecordType.new(@search_builder, options[:record_type]).call
      @search_builder = QueryBuilder::Facets.new(@search_builder, facet_list, facets_per_page, facets_offset).call
      @search_builder = QueryBuilder::Spellcheck.new(@search_builder, options[:suggest]).call
      @search_builder = QueryBuilder::Without.new(@search_builder, without_params).call
      @search_builder = QueryBuilder::WithBoudingBox.new(
        @search_builder, options[:geo_bbox]&.split(',')&.map(&:to_f)
      ).call
      @search_builder = QueryBuilder::FacetPivot.new(@search_builder, facet_pivot_list).call

      surpressed_source_ids = SupplejackApi::Source.suppressed.all.pluck(:source_id)
      @search_builder = QueryBuilder::Without.new(@search_builder, source_id: surpressed_source_ids).call

      restrictions = search_model.class.role_collection_restrictions(search_model.scope)
      @search_builder = QueryBuilder::Without.new(@search_builder, restrictions).call

      @search_builder = QueryBuilder::FacetRow.new(@search_builder, options[:facet_query]).call
      @search_builder = QueryBuilder::Ordering.new(
        @search_builder, SupplejackApi::Record, options[:sort], options[:direction]
      ).call
      @search_builder = QueryBuilder::Paginate.new(@search_builder, options[:page], options[:per_page]).call
      @search_builder = QueryBuilder::SolrQuery.new(@search_builder, options[:solr_query]).call

      @search_builder.build(&build_conditions)
      @search_builder
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def without_params
      return nil if options[:without].blank?

      options[:without].map do |name, values|
        [name, values.split(',').map { |value| to_proper_value(name, value) }.compact]
      end.to_h
    end

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

    def offset
      (page * per_page) - per_page
    end

    def facets_offset
      offset = (facets_page * facets_per_page) - facets_per_page
      offset.negative? ? 0 : offset
    end

    def records
      solr_search_object.results
    end

    # IMPORTANT !!!!
    #
    # Try to make this a bit prettier
    #
    INTEGER_ATTRIBUTES.each do |method|
      define_method(method) do
        value = @options[:"#{method.to_sym}"].to_i
        value = [value, self.class.max_values[method]].min if self.class.max_values[method]
        value
      end
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
        { and: options[:and], or: options[:or] }.each do |operator, value|
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
          if options[:exclude_filters_from_facets] == 'true'
            Utils.call_block(self, &filter_values(key, conditions, current_operator)) if facet_list.exclude?(key.to_sym)
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
          with(key, to_proper_value(key, values))
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
