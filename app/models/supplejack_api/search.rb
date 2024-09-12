# frozen_string_literal: true

module SupplejackApi
  class Search
    attr_accessor :options, :scope, :solr_request_params, :errors

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
      self.errors += options.errors

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
    def self.role_collection_exclusions(scope)
      role = scope&.role&.to_sym
      record_exclusions = schema_class.roles[role].record_exclusions

      return [] if scope.blank? || record_exclusions.blank?

      record_exclusions
    end

    # The records that match the criteria within each role will be
    # the only records returned in the search results
    def self.role_collection_inclusions(scope)
      role = scope&.role&.to_sym
      record_inclusions = schema_class.roles[role].record_inclusions

      return [] if scope.blank? || record_inclusions.blank?

      record_inclusions
    end

    # rubocop:disable Metrics/AbcSize
    def search_builder
      @search_builder ||= begin
        search = self.class
        restrictions = search.role_collection_exclusions(scope)
        inclusions = search.role_collection_inclusions(scope)
        suppressed_source_ids = SupplejackApi::Source.suppressed.all.pluck(:source_id)

        search = Sunspot.new_search(SupplejackApi::Record)
        search = QueryBuilder::RecordType.new(search, options.record_type).call
        search = QueryBuilder::Facets.new(search, options).call
        search = QueryBuilder::Spellcheck.new(search, options.suggest).call
        search = QueryBuilder::Without.new(search, options.without).call
        search = QueryBuilder::WithBoudingBox.new(search, options.geo_bbox).call
        search = QueryBuilder::SolrQuery.new(search, options.solr_query).call
        search = QueryBuilder::FacetPivot.new(search, options.facet_pivots).call
        search = QueryBuilder::Defaults.new(search).call
        search = QueryBuilder::FacetRow.new(search, options.facet_query).call
        search = QueryBuilder::Ordering.new(search, options).call
        search = QueryBuilder::Without.new(search, restrictions).call
        search = QueryBuilder::With.new(search, inclusions).call
        search = QueryBuilder::Without.new(search, source_id: suppressed_source_ids).call
        search = QueryBuilder::ExcludeFiltersFromFacets.new(search, options).call
        search = QueryBuilder::Paginate.new(search, options.page, options.per_page).call
        search = QueryBuilder::Group.new(search, options.group_by, options.group_order_by, options.group_sort).call
        search = QueryBuilder::AndOrFilters.new(search, options).call
        QueryBuilder::Keywords.new(search, options.text, options.query_fields).call
      end
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
  end
end
