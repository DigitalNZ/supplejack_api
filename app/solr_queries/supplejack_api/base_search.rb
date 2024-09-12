# frozen_string_literal: true

module SupplejackApi
  class BaseSearch
    attr_reader :options

    # used by ActiveModel::Serializer
    attr_reader :solr_request_params
    alias read_attribute_for_serialization send

    delegate :results, :total, to: :solr_query
    delegate :valid?, :errors, to: :options

    def initialize(options)
      @options = options
    end

    private

    def solr_query
      @solr_query ||= begin
        solr_query = query.execute
        @solr_request_params = solr_query.query.to_params if options.debug

        solr_query
      end
    end

    # The records that match the criteria within each role will be removed
    # from the search results
    def role_collection_exclusions(role)
      options.schema_class.roles[role.to_sym]&.record_exclusions
    end

    # The records that match the criteria within each role are the only
    # records that will be included in the search results
    def role_collection_inclusions(role)
      options.schema_class.roles[role.to_sym]&.record_inclusions
    end

    def query
      raise NotImplementedError, 'implement this in children classes'
    end
  end
end
