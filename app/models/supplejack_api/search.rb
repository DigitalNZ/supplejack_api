# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module SupplejackApi
  class Search
    def initialize(options = {})
      @options = options.dup
      @options.reverse_merge!(
        facets: '',
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
      return @facet_list if @facet_list

      @facet_list = options[:facets].split(',').map { |f| f.strip.to_sym }
      @facet_list.keep_if { |f| self.class.model_class.valid_facets.include?(f) }
      @facet_list
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

      if options[:query_fields].is_a?(String)
        query_field_list = options[:query_fields].split(',').map(&:strip).map(&:to_sym)
      elsif options[:query_fields].is_a?(Array)
        query_field_list = options[:query_fields].map(&:to_sym)
      end

      return nil if query_field_list.try(:empty?)
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
      if @text.present? && !@text.match(/:\"/)
        @text.downcase!
        @text.gsub!(/ and | or | not /, &:upcase)
      end
      @text
    end

    def valid?
      self.errors ||= []
      self.warnings ||= []
      self.class.max_values.each_key do |attribute|
        max_value = self.class.max_values[attribute]
        if @options[attribute].to_i > max_value
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

      if options[:debug] == 'true' && @solr_search_object.respond_to?(:query)
        self.solr_request_params = @solr_search_object.query.to_params
      end

      @solr_search_object
    end

    # QUESTION: Can this method be private?
    # If not, spec it
    def execute_solr_search
      search = search_builder

      search.build do
        keywords text, fields: query_fields
      end

      execute_solr_search_and_handle_errors(search)
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
        role = scope.role.try(:to_sym)
        if schema_class.roles[role].record_restrictions
          restrictions = schema_class.roles[role].record_restrictions
        end
      end

      restrictions
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # FIXME: Make this method smaller, it's triple the max method length
    def search_builder
      search_model = self

      @search_builder ||= Sunspot.new_search(SupplejackApi.config.record_class) do
        with(:record_type, record_type) unless options[:record_type] == 'all'

        search_model.facet_list.each do |facet_name|
          facet(facet_name, limit: facets_per_page, offset: facets_offset)
        end

        spellcheck collate: true, only_more_popular: true if options[:suggest]

        options[:without].each do |name, values|
          values = values.split(',')
          values.each do |value|
            without(name, to_proper_value(name, value))
          end
        end

        if options[:geo_bbox]
          coords = options[:geo_bbox].split(',').map(&:to_f)
          with(:lat_lng).in_bounding_box([coords[2], coords[1]], [coords[0], coords[3]])
        end

        adjust_solr_params do |params|
          if options[:solr_query].present?
            params[:q] ||= ''
            params['q.alt'] = options[:solr_query]
            params[:defType] = 'dismax'
          end
        end

        # Facet Queries
        #
        # The facet query parameter should have the following format:
        #
        #   facet_query: {images: {"creator" => "all"}, headings: {"record_type" => 1}}
        #
        # - Each key in the top level hash will be the name of each facet row returned.
        # - Each value in the top level hash is a hash similar with all the restrictions
        #

        if options[:facet_query].any?
          facet(:counts) do
            options[:facet_query].each_pair do |row_name, filters_hash|
              row(row_name.to_s) do
                filters_hash.each_pair do |filter, value|
                  if value == 'all'
                    without(filter.to_sym, nil)
                  elsif filter =~ /-(.+)/
                    without(Regexp.last_match(1).to_sym, to_proper_value(filter, value))
                  elsif value.is_a?(Array)
                    with(filter.to_sym).all_of(value)
                  else
                    with(filter.to_sym, to_proper_value(filter, value))
                  end
                end
              end
            end
          end
        end

        order_by(sort, direction) if options[:sort].present?

        search_model.class.role_collection_restrictions(search_model.scope).each do |field, values|
          without(field.to_sym, values)
        end

        SupplejackApi::Source.suppressed.each do |source|
          without(:source_id, source.source_id)
        end

        if options[:exclude_filters_from_facets] == 'true'
          or_and_options = {}.merge(options[:and]).merge(options[:or])
          or_and_options.each do |key, value|
            raise Exception, 'exclude_filters_from_facets does not allow nested (:and, :or)' if %i[or and].include? key
            facet(key.to_sym, exclude: with(key.to_sym, value))
          end
        end

        paginate page: page, per_page: per_page
      end

      @search_builder.build(&build_conditions) unless options[:exclude_filters_from_facets] == 'true'

      @search_builder
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

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

    def sort
      value = @options[:sort].to_sym

      begin
        Sunspot::Setup.for(self.class.model_class).field(value)
        return value
      rescue Sunspot::UnrecognizedFieldError
        return 'score'
      end
    end

    def direction
      if %w[asc desc].include?(@options[:direction])
        @options[:direction].to_sym
      else
        :desc
      end
    end

    # rubocop:disable Style/MethodMissing
    def method_missing(symbol, *args)
      return nil unless solr_search_object.respond_to?(:hits)
      solr_search_object.send(symbol, *args)
    end
    # rubocop:enable Style/MethodMissing

    def execute_solr_search_and_handle_errors(search)
      self.errors ||= []
      sunspot = search.execute
    rescue RSolr::Error::Http => e
      self.errors << e
      Rails.logger.info self.errors
      sunspot = {}
    ensure
      sunspot
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
          Utils.call_block(self, &filter_values(key, conditions, current_operator))
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

        if values.is_a?(Array)
          case operator.to_sym
          when :or
            with(key).any_of(values)
          when :and
            with(key).all_of(values)
          else
            raise Exception, 'Expected operator (:and, :or)'
          end
        elsif values =~ /(.+)\*$/
          with(key).starting_with(Regexp.last_match(1))
        else
          with(key, to_proper_value(key, values))
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
